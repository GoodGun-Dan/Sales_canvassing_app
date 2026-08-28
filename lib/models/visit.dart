class Visit {
  final int visitId;
  final int outletId;
  final String outletName;
  final String address;
  final String? visitTime;
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? visitReason;
  final String priority;
  final String? salesName;
  final DateTime visitDate;

  Visit({
    required this.visitId,
    required this.outletId,
    required this.outletName,
    required this.address,
    this.visitTime,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.visitReason,
    required this.priority,
    this.salesName,
    required this.visitDate,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      visitId: _toInt(json['visit_id']),
      outletId: _toInt(json['outlet_id']),
      outletName: _toString(json['outlet_name']),
      address: _toString(json['address']),
      visitTime: _toString(json['visit_time']),
      status: _toString(json['status']),
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'])
          : null,
      visitReason: _toString(json['visit_reason']),
      priority: _toString(json['priority']),
      salesName: _toString(json['sales_name']),
      visitDate: json['visit_date'] != null
          ? DateTime.tryParse(json['visit_date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'visit_id': visitId,
      'outlet_id': outletId,
      'outlet_name': outletName,
      'address': address,
      'visit_time': visitTime,
      'status': status,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'visit_reason': visitReason,
      'priority': priority,
    };
  }

  bool get isCompleted => status == 'Completed';
  bool get isMissed => status == 'Missed';
  bool get isPlanned => status == 'Planned';
  bool get isInProgress => status == 'InProgress';
}
