import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String defaultLanguage = 'id'; // Indonesian as default
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale(defaultLanguage));

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? defaultLanguage;
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    localeNotifier.value = Locale(languageCode);
  }

  static Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Login Screen
      'app_title': 'SalesCanvas',
      'app_subtitle': 'Mobile Sales Canvassing',
      'demo_credentials': 'Demo: repa/repa · repb/repb · manager/manager',
      'server': 'Server',
      'username': 'Username',
      'password': 'Password',
      'login': 'Login',
      'forgot_password': 'Forgot Password?',
      'username_required': 'Username required',
      'password_required': 'Password required',
      'login_failed': 'Login failed',

      // Common
      'required': 'Required',
      'email': 'Email',
      'phone': 'Phone',
      'name': 'Name',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'update': 'Update',
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading...',
      'no_data': 'No data available',

      // Dashboard
      'dashboard': 'Dashboard',
      'visits': 'Visits',
      'route_planning': 'Route Planning',
      'gps_tracking': 'GPS Tracking',
      'order_taking': 'Order Taking',
      'stock_management': 'Stock Management',
      'collections': 'Collections',
      'analytics': 'Analytics',
      'merchandising': 'Merchandising',
      'outlet_management': 'Outlet Management',
      'settings': 'Settings',
      'logout': 'Logout',
      'reports': 'Reports',
      'notifications': 'Notifications',
      'supervisor_dashboard': 'Supervisor Dashboard',
      'sales_team_management': 'Sales Team Management',
      'performance': 'Performance',
      'sales_today': 'Sales Today',
      'strike_rate': 'Strike Rate',
      'pending_sync': 'Pending Sync',
      'todays_visit_plan': "Today's Visit Plan",
      'no_visits_today': 'No visits scheduled today',
      'sync_status': 'Sync Status',
      'last_sync': 'Last sync',
      'online': 'Online',
      'try_again': 'Try Again',

      // Add/Edit Rep
      'add_sales_rep': 'Add Sales Rep',
      'edit_sales_rep': 'Edit Sales Rep',
      'full_name': 'Full Name',
      'auto_generate_username': 'Auto-generate username from name',
      'confirm_password': 'Confirm Password',
      'passwords_do_not_match': 'Passwords do not match',
      'sales_rep_added': 'Sales rep added',
      'sales_rep_updated': 'Sales rep updated',
      'invalid_email': 'Please enter a valid email',
      'invalid_phone':
          'Invalid phone format. Use Indonesian format (e.g., 08123456789)',
      'password_min_length': 'Password must be at least 8 characters',
      'password_uppercase': 'Password must contain at least 1 uppercase letter',
      'password_lowercase': 'Password must contain at least 1 lowercase letter',
      'password_number': 'Password must contain at least 1 number',
      'password_special': 'Password must contain at least 1 special character',

      // Language
      'language': 'Language',
      'english': 'English',
      'indonesian': 'Indonesian',
    },
    'id': {
      // Login Screen
      'app_title': 'SalesCanvas',
      'app_subtitle': 'Mobile Sales Canvassing',
      'demo_credentials': 'Demo: repa/repa · repb/repb · manager/manager',
      'server': 'Server',
      'username': 'Nama Pengguna',
      'password': 'Kata Sandi',
      'login': 'Masuk',
      'forgot_password': 'Lupa Kata Sandi?',
      'username_required': 'Nama pengguna diperlukan',
      'password_required': 'Kata sandi diperlukan',
      'login_failed': 'Gagal masuk',

      // Common
      'required': 'Diperlukan',
      'email': 'Email',
      'phone': 'Telepon',
      'name': 'Nama',
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'edit': 'Edit',
      'add': 'Tambah',
      'update': 'Perbarui',
      'success': 'Berhasil',
      'error': 'Error',
      'loading': 'Memuat...',
      'no_data': 'Tidak ada data',

      // Dashboard
      'dashboard': 'Dasbor',
      'visits': 'Kunjungan',
      'route_planning': 'Perencanaan Rute',
      'gps_tracking': 'Pelacakan GPS',
      'order_taking': 'Pengambilan Pesanan',
      'stock_management': 'Manajemen Stok',
      'collections': 'Pengumpulan',
      'analytics': 'Analitik',
      'merchandising': 'Merchandising',
      'outlet_management': 'Manajemen Outlet',
      'settings': 'Pengaturan',
      'logout': 'Keluar',
      'reports': 'Laporan',
      'notifications': 'Notifikasi',
      'supervisor_dashboard': 'Dasbor Supervisor',
      'sales_team_management': 'Manajemen Tim Sales',
      'performance': 'Performa',
      'sales_today': 'Penjualan Hari Ini',
      'strike_rate': 'Rasio Keberhasilan',
      'pending_sync': 'Menunggu Sinkronisasi',
      'todays_visit_plan': 'Rencana Kunjungan Hari Ini',
      'no_visits_today': 'Tidak ada kunjungan hari ini',
      'sync_status': 'Status Sinkronisasi',
      'last_sync': 'Sinkronisasi terakhir',
      'online': 'Online',
      'try_again': 'Coba Lagi',

      // Add/Edit Rep
      'add_sales_rep': 'Tambah Sales Rep',
      'edit_sales_rep': 'Edit Sales Rep',
      'full_name': 'Nama Lengkap',
      'auto_generate_username': 'Buat username otomatis dari nama',
      'confirm_password': 'Konfirmasi Kata Sandi',
      'passwords_do_not_match': 'Kata sandi tidak cocok',
      'sales_rep_added': 'Sales rep ditambahkan',
      'sales_rep_updated': 'Sales rep diperbarui',
      'invalid_email': 'Masukkan email yang valid',
      'invalid_phone':
          'Format telepon tidak valid. Gunakan format Indonesia (cth: 08123456789)',
      'password_min_length': 'Kata sandi minimal 8 karakter',
      'password_uppercase': 'Kata sandi harus mengandung minimal 1 huruf besar',
      'password_lowercase': 'Kata sandi harus mengandung minimal 1 huruf kecil',
      'password_number': 'Kata sandi harus mengandung minimal 1 angka',
      'password_special':
          'Kata sandi harus mengandung minimal 1 karakter khusus',

      // Language
      'language': 'Bahasa',
      'english': 'Inggris',
      'indonesian': 'Indonesia',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// Translates screen titles while retaining the existing screen APIs.
  String translateTitle(String title) {
    const titleKeys = {
      'Dashboard': 'dashboard',
      'Route Planning': 'route_planning',
      'GPS Tracking & Geofencing': 'gps_tracking',
      'Order Taking': 'order_taking',
      'Stock Management': 'stock_management',
      'Collections': 'collections',
      'Analytics': 'analytics',
      'Merchandising Audit': 'merchandising',
      'Outlet Management': 'outlet_management',
      'Settings': 'settings',
      'Reports': 'reports',
      'Notifications': 'notifications',
      'Supervisor Dashboard': 'supervisor_dashboard',
      'Sales Team Management': 'sales_team_management',
      'Kunjungan Hari Ini': 'visits',
      'Kelola Outlet (Manager)': 'outlet_management',
    };
    return get(titleKeys[title] ?? title);
  }
}

extension LocalizationContext on BuildContext {
  String tr(String key) => AppLocalizations.of(this).get(key);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
