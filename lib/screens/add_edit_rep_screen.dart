import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/sales_rep.dart';

class AddEditRepScreen extends StatefulWidget {
  final SalesRep? rep;
  final bool isManager;
  final bool requiresManagerSelection;

  const AddEditRepScreen({
    super.key,
    this.rep,
    this.isManager = false,
    this.requiresManagerSelection = false,
  });

  @override
  State<AddEditRepScreen> createState() => _AddEditRepScreenState();
}

class _AddEditRepScreenState extends State<AddEditRepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _autoGenerateUsername = true;
  List<Map<String, dynamic>> _managers = [];
  int? _managerId;

  @override
  void initState() {
    super.initState();
    if (widget.rep != null) {
      _nameController.text = widget.rep!.name;
      _emailController.text = widget.rep!.email;
      _phoneController.text = widget.rep!.phone;
      _usernameController.text = widget.rep!.username;
      _autoGenerateUsername = false;
    }
    if (widget.requiresManagerSelection) _loadManagers();
  }

  Future<void> _loadManagers() async {
    try {
      final managers = await AdminService.getManagers();
      if (mounted) setState(() => _managers = managers);
    } catch (_) {
      // The submit action will show the API error if manager data is unavailable.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Invalid phone format. Use Indonesian format (e.g., 08123456789)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least 1 lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!widget.isManager && widget.requiresManagerSelection && _managerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih manager untuk sales rep ini'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      if (widget.rep != null) {
        await AdminService.updateSalesRep(
          id: widget.rep!.employeeId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          username: _usernameController.text.trim(),
        );
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Sales rep updated'),
              backgroundColor: Colors.green),
        );
      } else {
        final username =
            _autoGenerateUsername ? null : _usernameController.text.trim();
        if (widget.isManager) {
          await AdminService.addManager(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            username: username,
            password: _passwordController.text.trim(),
          );
        } else {
          await AdminService.addSalesRep(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            username: username,
            password: _passwordController.text.trim(),
            managerId: _managerId,
          );
        }
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.isManager ? 'Manager added' : 'Sales rep added'),
            backgroundColor: Colors.green,
          ),
        );
      }
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rep != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Edit Sales Rep'
            : widget.isManager
                ? 'Add Manager'
                : 'Add Sales Rep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (!isEditing && !widget.isManager && widget.requiresManagerSelection) ...[
                DropdownButtonFormField<int>(
                  value: _managerId,
                  decoration: const InputDecoration(labelText: 'Manager', border: OutlineInputBorder()),
                  items: _managers.map((manager) => DropdownMenuItem<int>(
                    value: manager['employee_id'] as int,
                    child: Text(manager['name']?.toString() ?? 'Manager'),
                  )).toList(),
                  onChanged: (value) => setState(() => _managerId = value),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                CheckboxListTile(
                  title: const Text('Auto-generate username from name'),
                  value: _autoGenerateUsername,
                  onChanged: (value) {
                    setState(() {
                      _autoGenerateUsername = value ?? true;
                      if (_autoGenerateUsername) {
                        _usernameController.clear();
                      }
                    });
                  },
                ),
              ],
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    enabled: !_autoGenerateUsername || isEditing),
                validator: (v) {
                  if (!_autoGenerateUsername || isEditing) {
                    return v?.isEmpty ?? true ? 'Required' : null;
                  }
                  return null;
                },
              ),
              if (!isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isEditing
                          ? 'Update'
                          : widget.isManager
                              ? 'Add Manager'
                              : 'Add Sales Rep'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
