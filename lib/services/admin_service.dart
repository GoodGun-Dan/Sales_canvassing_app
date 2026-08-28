import 'api_client.dart';
import '../models/sales_rep.dart';
import 'package:intl/intl.dart';

class AdminService {
  static Future<List<SalesRep>> getSalesReps() async {
    try {
      final data = await ApiClient.get('/admin/sales-reps');
      print('📦 AdminService - Data received: ${data.runtimeType}');

      if (data is List) {
        return data.map((json) => SalesRep.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ getSalesReps error: $e');
      throw Exception('Failed to load sales reps: $e');
    }
  }

  static Future<Map<String, dynamic>> getRepDashboard(int repId) async {
    try {
      return await ApiClient.getMap('/admin/sales-reps/$repId/dashboard');
    } catch (e) {
      print('❌ getRepDashboard error: $e');
      throw Exception('Failed to load rep dashboard: $e');
    }
  }

  static Future<List<dynamic>> getRepOrders(int repId) async {
    try {
      final data = await ApiClient.get('/admin/sales-reps/$repId/orders');
      if (data is List) return data;
      return [];
    } catch (e) {
      print('❌ getRepOrders error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getRepPayments(int repId) async {
    try {
      final data = await ApiClient.get('/admin/sales-reps/$repId/payments');
      if (data is List) return data;
      return [];
    } catch (e) {
      print('❌ getRepPayments error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getRepAnalytics(
    int repId, {
    int? days,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String queryParams = '';
      if (startDate != null && endDate != null) {
        queryParams =
            '?start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}';
      } else if (days != null) {
        queryParams = '?days=$days';
      }
      return await ApiClient.getMap(
          '/admin/sales-reps/$repId/analytics$queryParams');
    } catch (e) {
      print('❌ getRepAnalytics error: $e');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getRepTransactions(
    int repId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String queryParams = '';
      if (startDate != null && endDate != null) {
        queryParams =
            '?start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}';
      }
      final data = await ApiClient.get(
          '/admin/sales-reps/$repId/transactions$queryParams');
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addSalesRep({
    required String name,
    required String email,
    required String phone,
    String? username,
    required String password,
    int? managerId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (username != null) {
      body['username'] = username;
    }
    if (managerId != null) body['manager_id'] = managerId;
    return await ApiClient.postMap('/admin/sales-reps', body);
  }

  static Future<Map<String, dynamic>> updateSalesRep({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String username,
    bool? isActive,
  }) async {
    return await ApiClient.putMap('/admin/sales-reps/$id', {
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'is_active': isActive,
    });
  }

  static Future<Map<String, dynamic>> deleteSalesRep(int id) async {
    return await ApiClient.deleteMap('/admin/sales-reps/$id');
  }

  static Future<Map<String, dynamic>> addManager({
    required String name,
    required String email,
    required String phone,
    String? username,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (username != null) body['username'] = username;
    return await ApiClient.postMap('/admin/managers', body);
  }

  // Compatibility wrapper for legacy settings UI. The backend still creates
  // a manager, never another admin account.
  static Future<Map<String, dynamic>> addAdmin({
    required String name,
    required String email,
    required String phone,
    String? username,
    required String password,
  }) => addManager(
    name: name, email: email, phone: phone, username: username, password: password,
  );

  static Future<List<Map<String, dynamic>>> getManagers() async {
    final data = await ApiClient.get('/admin/managers');
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }
}
