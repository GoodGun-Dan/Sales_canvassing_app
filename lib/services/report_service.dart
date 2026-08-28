import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/api_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ReportService {
  static Future<Map<String, dynamic>> sales({String? startDate, String? endDate}) =>
      _get('/reports/sales', startDate, endDate);

  static Future<Map<String, dynamic>> visits({String? startDate, String? endDate}) =>
      _get('/reports/visits', startDate, endDate);

  static Future<Map<String, dynamic>> performance({String? startDate, String? endDate}) =>
      _get('/reports/performance', startDate, endDate);

  static Future<Map<String, dynamic>> _get(String path, String? startDate, String? endDate) async {
    final query = <String>[];
    if (startDate?.isNotEmpty == true) query.add('start_date=$startDate');
    if (endDate?.isNotEmpty == true) query.add('end_date=$endDate');
    return ApiClient.getMap('$path${query.isEmpty ? '' : '?${query.join('&')}'}');
  }

  /// Downloads a report to the Android Downloads folder when storage access is
  /// available. App-specific external storage is used as a safe fallback.
  static Future<String> download({
    required String type,
    required String format,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String>['format=$format'];
    if (startDate?.isNotEmpty == true) query.add('start_date=$startDate');
    if (endDate?.isNotEmpty == true) query.add('end_date=$endDate');
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/${type.toLowerCase()}/download?${query.join('&')}'),
      headers: {if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengunduh laporan (${response.statusCode})');
    }

    Directory directory;
    if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    }
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${directory.path}/salescanvas_${type.toLowerCase()}_$timestamp.$format');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }
}
