import 'api_client.dart';
import '../models/stock_item.dart';

class StockService {
  static Future<List<StockItem>> fetchStock() async {
    try {
      final data = await ApiClient.get('/stock');
      print('📦 Stock data type: ${data.runtimeType}');

      if (data is List) {
        return data.map((json) => StockItem.fromJson(json)).toList();
      } else {
        print('❌ Stock data is not a List');
        return [];
      }
    } catch (e) {
      print('❌ fetchStock error: $e');
      throw Exception('Failed to load stock: $e');
    }
  }

  static Future<List<StockItem>> refreshStock() async {
    return fetchStock();
  }
}
