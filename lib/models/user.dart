class User {
  final int userId;
  final int employeeId;
  final String username;
  final String role;
  final String companyEmail;
  final bool isVerified;
  final int? managerId;
  final DateTime? lastLogin;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.employeeId,
    required this.username,
    required this.role,
    required this.companyEmail,
    required this.isVerified,
    this.managerId,
    this.lastLogin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: _toInt(json['user_id']),
      employeeId: _toInt(json['employee_id']),
      username: _toString(json['username']),
      role: _toString(json['role']),
      companyEmail: _toString(json['company_email']),
      isVerified: json['is_verified'] == true,
      managerId: json['manager_id'] != null ? _toInt(json['manager_id']) : null,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
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

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isSupervisor => role == 'supervisor';
  bool get isRep => role == 'rep';
}
