import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import '../services/outlet_service.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/outlet.dart';
import '../models/sales_rep.dart';
import '../widgets/app_drawer_scaffold.dart';
import '../config/api_config.dart';

class ManagerOutletScreen extends StatefulWidget {
  const ManagerOutletScreen({super.key});

  @override
  State<ManagerOutletScreen> createState() => _ManagerOutletScreenState();
}

class _ManagerOutletScreenState extends State<ManagerOutletScreen> {
  List<Outlet> _outlets = [];
  List<SalesRep> _salesReps = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadOutlets(),
        _loadSalesReps(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOutlets() async {
    try {
      final outlets = await OutletService.fetchOutlets();
      setState(() {
        _outlets = outlets;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading outlets: $e';
      });
    }
  }

  Future<void> _loadSalesReps() async {
    try {
      final data = await ApiClient.get('/admin/sales-reps');
      if (data is List) {
        final reps = data.map((json) => SalesRep.fromJson(json)).toList();
        setState(() {
          _salesReps = reps.where((r) => r.role == 'rep').toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(Outlet outlet) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Outlet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hapus ${outlet.outletName}?'),
            const SizedBox(height: 8),
            const Text(
              'Outlet ini akan dihapus dari semua sales rep dan kunjungan yang terkait akan dibatalkan.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() => _isLoading = true);
      try {
        await OutletService.deleteOutlet(outlet.outletId, force: true);
        await _loadData();
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
          content: Text('Outlet berhasil dihapus dari semua sales rep'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _assignOutletToRep(Outlet outlet) async {
    if (_salesReps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada sales rep tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedRep = await showDialog<SalesRep>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sales Rep'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _salesReps.length,
            itemBuilder: (context, index) {
              final rep = _salesReps[index];
              return ListTile(
                title: Text(rep.name),
                subtitle: Text(rep.email),
                onTap: () => Navigator.pop(context, rep),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedRep == null || !mounted) return;

    final visitDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (visitDate == null || !mounted) return;

    final visitTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      await ApiClient.post(
          '/admin/sales-reps/${selectedRep.employeeId}/assign-outlet', {
        'outlet_id': outlet.outletId,
        'visit_date': visitDate.toIso8601String().split('T')[0],
        'visit_time': visitTime != null
            ? '${visitTime.hour.toString().padLeft(2, '0')}:${visitTime.minute.toString().padLeft(2, '0')}:00'
            : '09:00:00',
      });
      await _loadData();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Outlet ${outlet.outletName} berhasil diassign ke ${selectedRep.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // ADD OUTLET FORM
  // =====================================================
  Future<void> _showOutletForm({Outlet? outlet}) async {
    final bool isEditing = outlet != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController codeController =
        TextEditingController(text: outlet?.outletCode ?? '');
    final TextEditingController nameController =
        TextEditingController(text: outlet?.outletName ?? '');
    final TextEditingController addressController =
        TextEditingController(text: outlet?.address ?? '');
    final TextEditingController latitudeController =
        TextEditingController(text: outlet?.latitude?.toString() ?? '');
    final TextEditingController longitudeController =
        TextEditingController(text: outlet?.longitude?.toString() ?? '');
    final TextEditingController ownerController =
        TextEditingController(text: outlet?.ownerName ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: outlet?.phone ?? '');
    final TextEditingController creditLimitController =
        TextEditingController(text: outlet?.creditLimit?.toString() ?? '');

    String selectedPriority = outlet?.priority ?? 'C';
    String selectedStoreType = outlet?.storeType ?? 'Retail';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Outlet' : 'Tambah Outlet Baru'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Outlet Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Outlet Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['A', 'B', 'C']
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedPriority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStoreType,
                      decoration: const InputDecoration(
                        labelText: 'Store Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        'Supermarket',
                        'Mini Market',
                        'Retail',
                        'Warung',
                        'Others'
                      ]
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedStoreType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ownerController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: creditLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Credit Limit',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() => _isLoading = true);

      try {
        final outletData = {
          'outlet_code': codeController.text,
          'outlet_name': nameController.text,
          'address': addressController.text,
          'latitude': latitudeController.text.isNotEmpty
              ? double.tryParse(latitudeController.text)
              : null,
          'longitude': longitudeController.text.isNotEmpty
              ? double.tryParse(longitudeController.text)
              : null,
          'priority': selectedPriority,
          'store_type': selectedStoreType,
          'owner_name': ownerController.text,
          'phone': phoneController.text,
          'credit_limit': creditLimitController.text.isNotEmpty
              ? double.tryParse(creditLimitController.text)
              : 0,
        };

        if (isEditing && outlet != null) {
          await OutletService.updateOutletFromMap(outlet.outletId, outletData);
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Outlet berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await OutletService.createOutletFromMap(outletData);
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Outlet berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _loadData();
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }

    codeController.dispose();
    nameController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    creditLimitController.dispose();
  }

  // =====================================================
  // UPLOAD OUTLET EXCEL
  // =====================================================
  Future<void> _showUploadOutletDialog() async {
    if (!mounted) return;
    if (!await Permission.storage.request().isGranted) return;

    String? selectedFileName;
    String? selectedFilePath;
    Uint8List? fileBytes;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Upload Outlet Excel'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Upload file Excel untuk tambah outlet baru.'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child:
                            Text(selectedFileName ?? 'Belum ada file dipilih')),
                    ElevatedButton(
                      onPressed: () async {
                        final pickResult = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx', 'xls'],
                          withData: true,
                        );
                        if (pickResult != null) {
                          setModalState(() {
                            selectedFileName = pickResult.files.first.name;
                            fileBytes = pickResult.files.first.bytes;
                            selectedFilePath = pickResult.files.first.path;
                          });
                        }
                      },
                      child: const Text('Pilih File'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  if (selectedFileName == null ||
                      (fileBytes == null && selectedFilePath == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pilih file terlebih dahulu'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && selectedFileName != null) {
      if (fileBytes != null) {
        await _uploadOutletFile(
            fileName: selectedFileName!, fileBytes: fileBytes!);
      } else if (selectedFilePath != null) {
        await _uploadOutletFileFromPath(
            fileName: selectedFileName!, filePath: selectedFilePath!);
      }
    }
  }

  Future<void> _uploadOutletFile({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/outlets/upload-excel');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final response = http.Response(responseBody, streamedResponse.statusCode);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        messenger.showSnackBar(
          SnackBar(
              content: Text(jsonResponse['message'] ?? 'Upload berhasil'),
              backgroundColor: Colors.green),
        );
        await _loadData();
      } else {
        final errorJson = jsonDecode(response.body);
        messenger.showSnackBar(
          SnackBar(
              content: Text(errorJson['error'] ?? 'Upload gagal'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _uploadOutletFileFromPath({
    required String fileName,
    required String filePath,
  }) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/outlets/upload-excel');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final response = http.Response(responseBody, streamedResponse.statusCode);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        messenger.showSnackBar(
          SnackBar(
              content: Text(jsonResponse['message'] ?? 'Upload berhasil'),
              backgroundColor: Colors.green),
        );
        await _loadData();
      } else {
        final errorJson = jsonDecode(response.body);
        messenger.showSnackBar(
          SnackBar(
              content: Text(errorJson['error'] ?? 'Upload gagal'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDrawerScaffold(
      title: 'Kelola Outlet (Manager)',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Tambah Outlet',
          onPressed: _showOutletForm,
        ),
        IconButton(
          icon: const Icon(Icons.upload_file),
          tooltip: 'Upload Excel',
          onPressed: _showUploadOutletDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOutlets,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOutlets,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOutlets,
                  child: _outlets.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('Tidak ada outlet')),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _outlets.length,
                          itemBuilder: (context, index) {
                            final outlet = _outlets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: outlet.priority == 'A'
                                      ? Colors.green
                                      : outlet.priority == 'B'
                                          ? Colors.orange
                                          : Colors.blue,
                                  child: Text(outlet.priority),
                                ),
                                title: Text(outlet.outletName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(outlet.address),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Code: ${outlet.outletCode} | Type: ${outlet.storeType}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Edit Outlet',
                                      onPressed: () =>
                                          _showOutletForm(outlet: outlet),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.person_add,
                                          color: Colors.green),
                                      tooltip: 'Assign ke Sales Rep',
                                      onPressed: () =>
                                          _assignOutletToRep(outlet),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _confirmDelete(outlet),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(outlet.outletName),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _detailRow(
                                                'Code', outlet.outletCode),
                                            _detailRow(
                                                'Address', outlet.address),
                                            _detailRow(
                                                'Priority', outlet.priority),
                                            _detailRow(
                                                'Store Type', outlet.storeType),
                                            _detailRow(
                                                'Owner', outlet.ownerName),
                                            _detailRow('Phone', outlet.phone),
                                            _detailRow(
                                              'Credit Limit',
                                              'Rp ${outlet.creditLimit.toStringAsFixed(0)}',
                                            ),
                                            if (outlet.latitude != null)
                                              _detailRow(
                                                'Location',
                                                '${outlet.latitude}, ${outlet.longitude}',
                                              ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tutup'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
