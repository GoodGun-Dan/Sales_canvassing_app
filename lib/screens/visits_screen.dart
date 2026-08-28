import 'package:flutter/material.dart';
import '../services/visit_service.dart';
import '../widgets/app_drawer_scaffold.dart';

class VisitsScreen extends StatefulWidget {
  final int? repId;
  final bool showTeamSchedule;

  const VisitsScreen({super.key, this.repId, this.showTeamSchedule = false});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Map<String, dynamic>> _visits = [];
  List<Map<String, dynamic>> _filteredVisits = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';

  final List<String> _statusOptions = [
    'All',
    'Planned',
    'InProgress',
    'Completed',
    'Missed',
    'Cancelled',
    'Permission',
    'Expired'
  ];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final visits = await VisitService.fetchTodayVisits(repId: widget.repId);
      if (!mounted) return;
      setState(() {
        _visits = visits;
        _filteredVisits = visits;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredVisits = _visits.where((visit) {
        // Status filter
        if (_selectedStatusFilter != 'All') {
          final status = visit['status']?.toString() ?? '';
          if (status != _selectedStatusFilter) return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final outletName =
              (visit['outlet_name']?.toString() ?? '').toLowerCase();
          final address = (visit['address']?.toString() ?? '').toLowerCase();
          if (!outletName.contains(_searchQuery.toLowerCase()) &&
              !address.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _markMissed(Map<String, dynamic> visit) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Missed Visit'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Alasan',
            hintText: 'Contoh: Outlet tutup',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final visitId = visit['visit_id'] is int
          ? visit['visit_id'] as int
          : int.parse(visit['visit_id'].toString());
      await VisitService.markMissed(
        visitId,
        reasonController.text.isEmpty ? 'Missed' : reasonController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit ditandai missed'),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadVisits();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelOrRequestPermission(Map<String, dynamic> visit) async {
    final reasonController = TextEditingController();
    final actionType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan atau Minta Ijin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Batalkan Kunjungan'),
              subtitle: const Text('Kunjungan akan hilang dari daftar'),
              onTap: () => Navigator.pop(context, 'cancel'),
            ),
            ListTile(
              leading: const Icon(Icons.request_page, color: Colors.orange),
              title: const Text('Minta Ijin'),
              subtitle: const Text('Tulis alasan untuk manager'),
              onTap: () => Navigator.pop(context, 'permission'),
            ),
          ],
        ),
      ),
    );

    if (actionType == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(actionType == 'cancel' ? 'Batalkan Kunjungan' : 'Minta Ijin'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText:
                actionType == 'cancel' ? 'Alasan pembatalan' : 'Alasan ijin',
            hintText: 'Contoh: Sakit, Urgensi keluarga, dll',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final visitId = visit['visit_id'] is int
          ? visit['visit_id'] as int
          : int.parse(visit['visit_id'].toString());
      await VisitService.cancelOrRequestPermission(
        visitId,
        actionType,
        reasonController.text.isEmpty
            ? (actionType == 'cancel'
                ? 'Dibatalkan oleh sales'
                : 'Meminta ijin')
            : reasonController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(actionType == 'cancel'
              ? 'Kunjungan dibatalkan'
              : 'Ijin dikirim ke manager'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadVisits();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'InProgress':
        return Colors.blue;
      case 'Missed':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      case 'Permission':
        return Colors.purple;
      case 'Expired':
        return Colors.brown;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _filteredVisits.isEmpty
                ? const Center(
                    child: Text('Tidak ada kunjungan yang sesuai filter'))
                : RefreshIndicator(
                    onRefresh: _loadVisits,
                    child: ListView.builder(
                      itemCount: _filteredVisits.length,
                      itemBuilder: (context, index) {
                        final v = _filteredVisits[index];
                        final status = v['status']?.toString() ?? 'Planned';
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(status),
                              child: Text(
                                v['priority']?.toString() ?? '-',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(v['outlet_name']?.toString() ?? ''),
                            subtitle: Text(
                              '${v['address']}\n'
                              '${widget.showTeamSchedule ? 'Sales: ${v['sales_name'] ?? '-'}\n' : ''}'
                              'Jam: ${v['visit_time'] ?? '-'} | $status\n'
                              'Check-in: ${v['check_in_time'] ?? '-'}',
                            ),
                            isThreeLine: true,
                            trailing: !widget.showTeamSchedule &&
                                    (status == 'Planned' ||
                                        status == 'InProgress')
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _cancelOrRequestPermission(v),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.report_problem,
                                            color: Colors.orange),
                                        onPressed: () => _markMissed(v),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  );

    final filterRow = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari outlet atau alamat...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 8),
          // Status filter dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter Status',
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: _selectedStatusFilter,
            items: _statusOptions.map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatusFilter = value;
                });
                _applyFilters();
              }
            },
          ),
        ],
      ),
    );

    if (widget.repId != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.showTeamSchedule
              ? 'Jadwal Kunjungan Tim Hari Ini'
              : 'Kunjungan Hari Ini'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVisits),
          ],
        ),
        body: Column(
          children: [
            filterRow,
            Expanded(child: body),
          ],
        ),
      );
    }

    return AppDrawerScaffold(
      title: widget.showTeamSchedule
          ? 'Jadwal Kunjungan Tim Hari Ini'
          : 'Kunjungan Hari Ini',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVisits),
      ],
      body: Column(
        children: [
          filterRow,
          Expanded(child: body),
        ],
      ),
    );
  }
}
