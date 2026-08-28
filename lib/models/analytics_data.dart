class AnalyticsData {
  final List<DailySales> dailySales;
  final List<TopProduct> topProducts;
  final List<TopOutlet> topOutlets;
  final AnalyticsSummary summary;

  AnalyticsData({
    required this.dailySales,
    required this.topProducts,
    required this.topOutlets,
    required this.summary,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    final dailySalesList = json['dailySales'] as List?;
    final topProductsList = json['topProducts'] as List?;
    final topOutletsList = json['topOutlets'] as List?;

    return AnalyticsData(
      dailySales:
          dailySalesList?.map((e) => DailySales.fromJson(e)).toList() ?? [],
      topProducts:
          topProductsList?.map((e) => TopProduct.fromJson(e)).toList() ?? [],
      topOutlets:
          topOutletsList?.map((e) => TopOutlet.fromJson(e)).toList() ?? [],
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class DailySales {
  final DateTime date;
  final double totalSales;

  DailySales({
    required this.date,
    required this.totalSales,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      totalSales: _toDouble(json['total_sales']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TopProduct {
  final String productName;
  final int totalQuantity;
  final double totalSales;

  TopProduct({
    required this.productName,
    required this.totalQuantity,
    required this.totalSales,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productName: json['product_name']?.toString() ?? '',
      totalQuantity: _toInt(json['total_quantity']),
      totalSales: _toDouble(json['total_sales']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TopOutlet {
  final String outletName;
  final int totalVisits;
  final double totalSales;

  TopOutlet({
    required this.outletName,
    required this.totalVisits,
    required this.totalSales,
  });

  factory TopOutlet.fromJson(Map<String, dynamic> json) {
    return TopOutlet(
      outletName: json['outlet_name']?.toString() ?? '',
      totalVisits: _toInt(json['total_visits']),
      totalSales: _toDouble(json['total_sales']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class AnalyticsSummary {
  final double totalSales;
  final int totalOrders;
  final int totalVisits;
  final double strikeRate;

  AnalyticsSummary({
    required this.totalSales,
    required this.totalOrders,
    required this.totalVisits,
    required this.strikeRate,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalSales: _toDouble(json['total_sales']),
      totalOrders: _toInt(json['total_orders']),
      totalVisits: _toInt(json['total_visits']),
      strikeRate: _toDouble(json['strike_rate']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
