import 'package:flutter/material.dart';
import '../widgets/app_drawer_scaffold.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/sales_rep.dart';
import '../login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _userRole = '';
  List<SalesRep> _admins = [];

  // Controllers for edit profile
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Controllers for change password
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Controllers for add admin
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerEmailController = TextEditingController();
  final TextEditingController _managerPhoneController = TextEditingController();
  final TextEditingController _managerUsernameController =
      TextEditingController();
  final TextEditingController _managerPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _managerNameController.dispose();
    _managerEmailController.dispose();
    _managerPhoneController.dispose();
    _managerUsernameController.dispose();
    _managerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await UserService.getProfile();
      final role = await AuthService.getUserRole();

      setState(() {
        _profile = profile;
        _userRole = role;
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadAdmins() async {
    try {
      final reps = await AdminService.getSalesReps();
      setState(() {
        _admins = reps.where((r) => r.role == 'admin').toList();
      });
    } catch (e) {
      debugPrint('Error loading admins: $e');
    }
  }

  Future<void> _addAdmin() async {
    final name = _managerNameController.text.trim();
    final email = _managerEmailController.text.trim();
    final phone = _managerPhoneController.text.trim();
    final username = _managerUsernameController.text.trim();
    final password = _managerPasswordController.text;
    String? validationError;
    if (name.length < 2) {
      validationError = 'Nama minimal 2 karakter';
    } else if (!RegExp(r'^[\w.+-]+@[\w-]+(?:\.[\w-]+)+$').hasMatch(email)) {
      validationError = 'Format email tidak valid';
    } else if (!RegExp(r'^(?:\+62|62|0)[0-9]{9,12}$')
        .hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''))) {
      validationError = 'Nomor telepon Indonesia tidak valid';
    } else if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{2,49}$')
        .hasMatch(username)) {
      validationError = 'Username 3–50 karakter; hanya huruf, angka, titik, garis bawah, atau strip';
    } else if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?\":{}|<>]').hasMatch(password)) {
      validationError = 'Password minimal 8 karakter dan harus memuat huruf besar, huruf kecil, angka, serta karakter khusus';
    }

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await AdminService.addAdmin(
        name: name,
        email: email,
        phone: phone,
        username: username,
        password: password,
      );

      _managerNameController.clear();
      _managerEmailController.clear();
      _managerPhoneController.clear();
      _managerUsernameController.clear();
      _managerPasswordController.clear();

      await _loadAdmins();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Admin berhasil ditambahkan'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddAdminDialog() {
    _managerNameController.clear();
    _managerEmailController.clear();
    _managerPhoneController.clear();
    _managerUsernameController.clear();
    _managerPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Admin'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _managerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _managerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _managerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _managerUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _managerPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _addAdmin,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.length < 2 ||
        !RegExp(r'^[\w.+-]+@[\w-]+(?:\.[\w-]+)+$').hasMatch(email) ||
        !RegExp(r'^(?:\+62|62|0)[0-9]{9,12}$')
            .hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa nama, email, dan nomor telepon Anda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirmation do not match'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (newPassword.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(newPassword) ||
        !RegExp(r'[a-z]').hasMatch(newPassword) ||
        !RegExp(r'[0-9]').hasMatch(newPassword) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 8 karakter serta memuat huruf besar, huruf kecil, angka, dan karakter khusus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.changePassword(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: newPassword,
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _oldPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDrawerScaffold(
      title: 'Settings',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    // Profile Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    _profile['name']?.isNotEmpty == true
                                        ? _profile['name'][0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _profile['name'] ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _profile['email'] ?? '',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _userRole == 'manager' ||
                                                  _userRole == 'admin'
                                              ? Colors.orange.shade100
                                              : Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _userRole.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _userRole == 'manager' ||
                                                    _userRole == 'admin'
                                                ? Colors.orange.shade800
                                                : Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ListTile(
                              leading:
                                  const Icon(Icons.edit, color: Colors.blue),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _showEditProfileDialog,
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.lock, color: Colors.orange),
                              title: const Text('Change Password'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _showChangePasswordDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // The system has one fixed admin account; account creation is
                    // available from the team-management screen instead.
                    if (false)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Administrators',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _showAddAdminDialog,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Tambah'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              if (_admins.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Belum ada admin lain'),
                                )
                              else
                                ..._admins.map((manager) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          manager.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(manager.name),
                                      subtitle: Text(manager.email),
                                      trailing: manager.isActive
                                          ? const Icon(Icons.check_circle,
                                              color: Colors.green)
                                          : const Icon(Icons.cancel,
                                              color: Colors.red),
                                    )),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // App Info Section
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.info, color: Colors.blue),
                              title: Text('Version'),
                              trailing: Text('1.0.0'),
                              onTap: null,
                            ),
                            ListTile(
                              leading: Icon(Icons.build, color: Colors.purple),
                              title: Text('Developer'),
                              trailing: Text('SalesCanvas Team'),
                              onTap: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logout Button
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.red),
                          onTap: _logout,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        '© 2026 SalesCanvas\nMobile Sales Canvassing Application',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
    );
  }
}
