class Order {
  final int orderId;
  final String orderNumber;
  final String orderType;
  final String outletName;
  final double total;
  final DateTime orderDate;
  final String status;
  final String? salesName;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.orderType,
    required this.outletName,
    required this.total,
    required this.orderDate,
    required this.status,
    this.salesName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: _toInt(json['order_id']),
      orderNumber: _toString(json['order_number']),
      orderType: _toString(json['order_type']),
      outletName: _toString(json['outlet_name']),
      total: _toDouble(json['total']),
      orderDate: json['order_date'] != null
          ? DateTime.tryParse(json['order_date']) ?? DateTime.now()
          : DateTime.now(),
      status: _toString(json['status']),
      salesName: _toString(json['sales_name']),
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

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'order_type': orderType,
      'outlet_name': outletName,
      'total': total,
      'order_date': orderDate.toIso8601String(),
      'status': status,
    };
  }

  bool get isSynced => status == 'Synced';
  bool get isPending => status == 'Pending';
}
