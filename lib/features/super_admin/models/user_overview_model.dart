class UserOverviewModel {
  final int totalUsers;
  final int superAdmins;
  final int admins;
  final int coreTeam;
  final int members;
  final int students;

  const UserOverviewModel({
    required this.totalUsers,
    required this.superAdmins,
    required this.admins,
    required this.coreTeam,
    required this.members,
    required this.students,
  });

  factory UserOverviewModel.fromJson(Map<String, dynamic> json) {
    final roles = Map<String, dynamic>.from(
      json['roles'] as Map? ?? const {},
    );

    return UserOverviewModel(
      totalUsers: _toInt(json['totalUsers']),
      superAdmins: _toInt(roles['SUPER_ADMIN']),
      admins: _toInt(roles['ADMIN']),
      coreTeam: _toInt(roles['CORE_TEAM']),
      members: _toInt(roles['MEMBER']),
      students: _toInt(roles['STUDENT']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
