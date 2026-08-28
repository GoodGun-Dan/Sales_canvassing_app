import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  int _currentStep = 0; // 0: Email, 1: Code, 2: New Password

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Email wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final result =
          await AuthService.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _successMessage =
              result['message'] ?? 'Kode verifikasi telah dikirim ke email';
          _currentStep = 1;
        });

        // For testing, show the code
        if (result['code'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kode verifikasi (testing): ${result['code']}'),
              duration: const Duration(seconds: 10),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        setState(() => _errorMessage =
            result['error'] ?? 'Gagal mengirim kode verifikasi');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Kode verifikasi wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final result = await AuthService.verifyCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );

      if (result['success'] == true) {
        setState(() {
          _successMessage = result['message'] ?? 'Kode verifikasi valid';
          _currentStep = 2;
        });
      } else {
        setState(() =>
            _errorMessage = result['error'] ?? 'Kode verifikasi tidak valid');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Password baru wajib diisi');
      return;
    }

    final password = _newPasswordController.text.trim();

    // Password validation matching backend requirements
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password minimal 8 karakter');
      return;
    }

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
      setState(() => _errorMessage =
          'Password harus mengandung minimal 1 huruf besar, 1 huruf kecil, 1 angka, dan 1 karakter khusus');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Password tidak cocok');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final result = await AuthService.resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah. Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        setState(
            () => _errorMessage = result['error'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width > 600 ? 400 : double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(33, 150, 243, 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _goBack,
                              padding: EdgeInsets.zero,
                            ),
                            Expanded(
                              child: Text(
                                'Lupa Password',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade700],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lock_reset,
                              size: isSmallScreen ? 40 : 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getStepTitle(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStepDescription(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Step indicator
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepIndicator(0, 'Email'),
                              _buildStepConnector(),
                              _buildStepIndicator(1, 'Kode'),
                              _buildStepConnector(),
                              _buildStepIndicator(2, 'Password'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: isSmallScreen ? 11 : 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_successMessage.isNotEmpty && _currentStep < 2)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage,
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: isSmallScreen ? 11 : 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildStepContent(),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _getCurrentStepAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _getButtonText(),
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Masukkan Email';
      case 1:
        return 'Verifikasi Kode';
      case 2:
        return 'Password Baru';
      default:
        return '';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Masukkan email yang terdaftar untuk menerima kode verifikasi';
      case 1:
        return 'Masukkan kode verifikasi 6 digit yang dikirim ke email Anda';
      case 2:
        return 'Buat password baru untuk akun Anda';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return TextField(
          controller: _emailController,
          autofillHints: const [AutofillHints.email],
          style: const TextStyle(color: Colors.black87),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.blue, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
        );
      case 1:
        return TextField(
          controller: _codeController,
          style: const TextStyle(color: Colors.black87),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Kode Verifikasi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.verified_user, color: Colors.blue, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          enabled: !_isLoading,
        );
      case 2:
        return Column(
          children: [
            TextField(
              controller: _newPasswordController,
              autofillHints: const [AutofillHints.newPassword],
              style: const TextStyle(color: Colors.black87),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                prefixIcon:
                    const Icon(Icons.lock, color: Colors.blue, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              autofillHints: const [AutofillHints.newPassword],
              style: const TextStyle(color: Colors.black87),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Colors.blue, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  VoidCallback? get _getCurrentStepAction {
    switch (_currentStep) {
      case 0:
        return () {
          _sendCode();
        };
      case 1:
        return () {
          _verifyCode();
        };
      case 2:
        return () {
          _resetPassword();
        };
      default:
        return null;
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Kirim Kode';
      case 1:
        return 'Verifikasi';
      case 2:
        return 'Reset Password';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).primaryColor
                : isCompleted
                    ? Colors.green
                    : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.grey[300],
    );
  }
}
