import 'package:flutter/material.dart';
import 'config/api_config.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'main.dart';
import 'screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _currentLanguage = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = lang;
      });
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    await LanguageService.setLanguage(langCode);
    if (mounted) {
      setState(() {
        _currentLanguage = langCode;
      });
    }
  }

  String _getText(String key) {
    final texts = {
      'id': {
        'username': 'Nama Pengguna',
        'password': 'Kata Sandi',
        'login': 'Masuk',
        'forgot_password': 'Lupa Kata Sandi?',
        'username_required': 'Nama pengguna diperlukan',
        'password_required': 'Kata sandi diperlukan',
        'login_failed': 'Gagal masuk',
      },
      'en': {
        'username': 'Username',
        'password': 'Password',
        'login': 'Login',
        'forgot_password': 'Forgot Password?',
        'username_required': 'Username required',
        'password_required': 'Password required',
        'login_failed': 'Login failed',
      }
    };
    return texts[_currentLanguage]?[key] ?? texts['en']?[key] ?? key;
  }

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _errorMessage = _getText('username_required');
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = _getText('password_required');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(username, password);

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleBasedNavigator()),
        );
        return;
      }

      setState(() {
        _errorMessage = result['error'] ?? _getText('login_failed');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Provide more user-friendly error messages
        String errorText = 'Error: $e';
        if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timed out')) {
          errorText = 'Server tidak merespons. Periksa koneksi internet Anda.';
        } else if (e.toString().contains('Connection refused')) {
          errorText =
              'Tidak dapat terhubung ke server. Pastikan backend berjalan.';
        } else if (e.toString().contains('Network')) {
          errorText = 'Masalah jaringan. Periksa koneksi internet Anda.';
        }
        _errorMessage = errorText;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              // Keep the card centered on tall screens, while allowing the
              // complete form to scroll on compact screens or with keyboard open.
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
                        const SizedBox(height: 8),
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
                              Icons.storefront,
                              size: isSmallScreen ? 40 : 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SalesCanvas',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mobile Sales Canvassing',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Language Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.language,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButton<String>(
                                value: _currentLanguage,
                                underline: const SizedBox.shrink(),
                                isDense: true,
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 12),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'id', child: Text('ID')),
                                  DropdownMenuItem(
                                      value: 'en', child: Text('EN')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    _changeLanguage(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Username field
                        TextField(
                          controller: _usernameController,
                          autofillHints: const [AutofillHints.username],
                          style: const TextStyle(color: Colors.black87),
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                            labelText: _getText('username'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
                            prefixIcon: const Icon(Icons.person,
                                color: Colors.blue, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          style: const TextStyle(color: Colors.black87),
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                            labelText: _getText('password'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
                            prefixIcon: const Icon(Icons.lock,
                                color: Colors.blue, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Login button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
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
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _getText('login'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_errorMessage != null)
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
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              _getText('forgot_password'),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
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
}
