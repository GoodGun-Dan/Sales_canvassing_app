class MerchandisingAudit {
  final int auditId;
  final int visitId;
  final int? planogramScore;
  final int? shelfShare;
  final bool posmPlacement;
  final String? notes;
  final DateTime createdAt;

  MerchandisingAudit({
    required this.auditId,
    required this.visitId,
    this.planogramScore,
    this.shelfShare,
    required this.posmPlacement,
    this.notes,
    required this.createdAt,
  });

  factory MerchandisingAudit.fromJson(Map<String, dynamic> json) {
    return MerchandisingAudit(
      auditId: _toInt(json['audit_id']),
      visitId: _toInt(json['visit_id']),
      planogramScore: json['planogram_score'] != null
          ? _toInt(json['planogram_score'])
          : null,
      shelfShare:
          json['shelf_share'] != null ? _toInt(json['shelf_share']) : null,
      posmPlacement: json['posm_placement'] == true,
      notes: _toString(json['notes']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
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
      'audit_id': auditId,
      'visit_id': visitId,
      'planogram_score': planogramScore,
      'shelf_share': shelfShare,
      'posm_placement': posmPlacement,
      'notes': notes,
    };
  }
}
