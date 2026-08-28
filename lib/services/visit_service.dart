import 'api_client.dart';

class VisitService {
  static Future<List<Map<String, dynamic>>> fetchTodayVisits(
      {int? repId}) async {
    final endpoint =
        repId != null ? '/visits/today?rep_id=$repId' : '/visits/today';
    final data = await ApiClient.get(endpoint);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<Map<String, dynamic>> checkIn({
    required int outletId,
    required double latitude,
    required double longitude,
    String? visitReason,
  }) async {
    return await ApiClient.post('/visits/checkin', {
      'outletId': outletId,
      'latitude': latitude,
      'longitude': longitude,
      'visitReason': visitReason ?? 'Regular Sales Call',
    });
  }

  static Future<Map<String, dynamic>> checkOut(int visitId) async {
    return await ApiClient.post('/visits/checkout', {'visitId': visitId});
  }

  static Future<void> markMissed(int visitId, String reason) async {
    await ApiClient.post('/visits/$visitId/missed', {'reason': reason});
  }

  static Future<void> requestPermission(int visitId, String reason) async {
    await ApiClient.post(
        '/visits/$visitId/cancel-permission', {
      'action_type': 'permission',
      'reason': reason,
    });
  }

  static Future<void> reschedule(
    int visitId, {
    required String visitDate,
    String? visitTime,
  }) async {
    await ApiClient.post('/visits/$visitId/reschedule', {
      'visit_date': visitDate,
      if (visitTime != null) 'visit_time': visitTime,
    });
  }

  static Future<void> cancelOrRequestPermission(
    int visitId,
    String actionType,
    String reason,
  ) async {
    await ApiClient.post('/visits/$visitId/cancel-permission', {
      'action_type': actionType,
      'reason': reason,
    });
  }
}
