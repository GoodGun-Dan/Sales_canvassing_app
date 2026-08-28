import 'api_client.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> fetchAll() async {
    final data = await ApiClient.get('/notifications');
    return data is List
        ? data.map((item) => Map<String, dynamic>.from(item as Map)).toList()
        : [];
  }

  static Future<void> markRead(int id) =>
      ApiClient.put('/notifications/$id/read', {});

  static Future<void> markAllRead() => ApiClient.put('/notifications/read-all', {});
}
