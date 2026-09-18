class PeopleUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? rollNumber;
  final String? department;
  final int? yearOfStudy;
  final String? avatarUrl;
  final String? bio;
  final String status;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int eventsAttended;
  final int totalEvents;

  /// Final CampusConnect model: exactly one role per user.
  final PeopleRole role;

  /// Compatibility getter for the existing SUPER_ADMIN People UI.
  ///
  /// The old UI expects `roles[]`, but the actual platform now has
  /// exactly one role. We expose a one-item compatibility list so
  /// the existing UI can remain intact until the final cleanup.
  List<UserRoleAssignment> get roles => [
        UserRoleAssignment(
          id: 'single-role-$id',
          userId: id,
          roleId: role.id,
          assignedAt: role.updatedAt,
          role: role,
        ),
      ];

  const PeopleUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.rollNumber,
    this.department,
    this.yearOfStudy,
    this.avatarUrl,
    this.bio,
    required this.status,
    required this.isEmailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    required this.eventsAttended,
    required this.totalEvents,
    required this.role,
  });

  factory PeopleUser.fromJson(
    Map<String, dynamic> json,
  ) {
    final roleJson = json['role'] as Map<String, dynamic>?;

    final legacyRoles = json['roles'];

    Map<String, dynamic> resolvedRole = roleJson ?? const {};

    // Current backend returns a single UserRole object:
    // { ... , roles: { role: { name: 'STUDENT', ... } } }
    // Older responses used a list of role assignments. Support both.
    if (resolvedRole.isEmpty && legacyRoles is Map) {
      final nestedRole = legacyRoles['role'];

      if (nestedRole is Map) {
        resolvedRole = Map<String, dynamic>.from(nestedRole);
      }
    }

    if (resolvedRole.isEmpty && legacyRoles is List && legacyRoles.isNotEmpty) {
      final firstRole = legacyRoles.first;

      if (firstRole is Map) {
        final nestedRole = firstRole['role'];

        if (nestedRole is Map) {
          resolvedRole = Map<String, dynamic>.from(nestedRole);
        }
      }
    }

    return PeopleUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      rollNumber: json['rollNumber'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['yearOfStudy'] as int?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastLoginAt: _parseDate(
        json['lastLoginAt'],
      ),
      createdAt: _parseDate(
            json['createdAt'],
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
      updatedAt: _parseDate(
            json['updatedAt'],
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
      eventsAttended: (json['stats'] is Map ? (json['stats']['eventsAttended'] as num?)?.toInt() : null) ?? 0,
      totalEvents: (json['stats'] is Map ? (json['stats']['totalEvents'] as num?)?.toInt() : null) ?? 0,
      role: PeopleRole.fromJson(
        resolvedRole,
      ),
    );
  }

  String get primaryRole {
    return role.name.isEmpty ? 'STUDENT' : role.name;
  }

  List<String> get roleNames => [
        primaryRole,
      ];

  bool hasRole(
    String roleName,
  ) {
    return primaryRole == roleName;
  }

  bool get isActive => status == 'ACTIVE';

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return DateTime.tryParse(
        value,
      );
    }

    return null;
  }
}

class UserRoleAssignment {
  final String id;
  final String userId;
  final String roleId;
  final DateTime assignedAt;
  final PeopleRole role;

  const UserRoleAssignment({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.assignedAt,
    required this.role,
  });

  factory UserRoleAssignment.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserRoleAssignment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      roleId: json['roleId'] as String? ?? '',
      assignedAt: DateTime.tryParse(
            json['assignedAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
      role: PeopleRole.fromJson(
        json['role'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class PeopleRole {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic>? permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PeopleRole({
    required this.id,
    required this.name,
    this.description,
    this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeopleRole.fromJson(
    Map<String, dynamic> json,
  ) {
    return PeopleRole(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      permissions: json['permissions'] is Map
          ? Map<String, dynamic>.from(
              json['permissions'] as Map,
            )
          : null,
      createdAt: DateTime.tryParse(
            json['createdAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
      updatedAt: DateTime.tryParse(
            json['updatedAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
    );
  }
}

class PeoplePagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PeoplePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PeoplePagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return PeoplePagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

class PeopleListResponse {
  final List<PeopleUser> users;
  final PeoplePagination pagination;

  const PeopleListResponse({
    required this.users,
    required this.pagination,
  });

  factory PeopleListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawUsers = json['users'] as List<dynamic>? ?? const [];

    return PeopleListResponse(
      users: rawUsers
          .whereType<Map<String, dynamic>>()
          .map(
            PeopleUser.fromJson,
          )
          .toList(
            growable: false,
          ),
      pagination: PeoplePagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
