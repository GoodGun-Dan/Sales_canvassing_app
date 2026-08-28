class TeamMember {
  final int employeeId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime joinedDate;

  TeamMember({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.joinedDate,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      employeeId: _toInt(json['employee_id']),
      name: _toString(json['name']),
      email: _toString(json['Email'] ?? json['email']),
      phone: _toString(json['phone']),
      role: _toString(json['role']),
      joinedDate: json['joined_date'] != null
          ? DateTime.tryParse(json['joined_date']) ?? DateTime.now()
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
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'joined_date': joinedDate.toIso8601String(),
    };
  }
}
