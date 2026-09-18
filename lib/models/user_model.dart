import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? department;
  final String? rollNumber;
  final String? avatarUrl;
  final String? bio;
  final String role;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.department,
    this.rollNumber,
    this.avatarUrl,
    this.bio,
    required this.role,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      department: json['department'] as String?,
      rollNumber: json['rollNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      role: (json['role'] as String?) ?? 'STUDENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'rollNumber': rollNumber,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'role': role,
    };
  }

  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isAdmin => role == 'ADMIN';

  bool get isCoreTeam => role == 'CORE_TEAM';

  bool get isMember => role == 'MEMBER';

  bool get isStudent => role == 'STUDENT';

  bool get hasAdministrativeAccess => isSuperAdmin || isAdmin;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        department,
        rollNumber,
        avatarUrl,
        bio,
        role,
      ];
}
