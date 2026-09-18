import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';

class AdminPerson {
  final String id;
  final String name;
  final String email;
  final String role;

  const AdminPerson({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  AdminPerson copyWith({
    String? role,
  }) {
    return AdminPerson(
      id: id,
      name: name,
      email: email,
      role: role ?? this.role,
    );
  }
}

class AdminPeopleScreen extends StatefulWidget {
  final String role;

  const AdminPeopleScreen({
    super.key,
    required this.role,
  });

  @override
  State<AdminPeopleScreen> createState() => _AdminPeopleScreenState();
}

class _AdminPeopleScreenState extends State<AdminPeopleScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<AdminPerson> _users = [
    AdminPerson(
      id: 'admin-user-001',
      name: 'Rahul Kumar',
      email: 'rahul@example.com',
      role: 'MEMBER',
    ),
    AdminPerson(
      id: 'admin-user-002',
      name: 'Ananya Rao',
      email: 'ananya@example.com',
      role: 'CORE_TEAM',
    ),
    AdminPerson(
      id: 'admin-user-003',
      name: 'Vikram Shetty',
      email: 'vikram@example.com',
      role: 'STUDENT',
    ),
  ];

  String _filter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminPerson> get _filtered {
    final query = _searchController.text.trim().toLowerCase();

    return _users.where((user) {
      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      final matchesRole = _filter == 'ALL' || user.role == _filter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USER MANAGEMENT',
                    style: AppTextStyles.labelSmall(
                      AppColors.secondary,
                    ).copyWith(
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    'People',
                    style: AppTextStyles.displayMedium(
                      AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Manage operational campus users.',
                    style: AppTextStyles.bodyMedium(
                      AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimens.radiusFull,
                ),
              ),
              child: Text(
                '${_users.length} users',
                style: AppTextStyles.labelSmall(
                  AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppDimens.space20,
        ),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.search_rounded,
            ),
            hintText: 'Search name or email...',
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _roleFilters.length,
            separatorBuilder: (_, __) => const SizedBox(
              width: 8,
            ),
            itemBuilder: (_, index) {
              final role = _roleFilters[index];

              return _FilterChip(
                label: role,
                selected: role == _filter,
                onTap: () {
                  setState(() {
                    _filter = role;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(
          height: AppDimens.space16,
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text(
                    'No users found.',
                    style: AppTextStyles.bodyMedium(
                      AppColors.darkTextSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(
                    height: 10,
                  ),
                  itemBuilder: (_, index) {
                    final user = _filtered[index];

                    return _PersonCard(
                      user: user,
                      onChangeRole: () => _changeRole(
                        user,
                      ),
                      onDelete: () => _deleteUser(
                        user,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<String> get _roleFilters => const [
        'ALL',
        'CORE_TEAM',
        'MEMBER',
        'STUDENT',
      ];

  Future<void> _changeRole(
    AdminPerson user,
  ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: AppColors.darkSurfaceElevated,
        title: const Text(
          'Assign role',
        ),
        children: const [
          SimpleDialogOption(
            child: Text('CORE_TEAM'),
          ),
          SimpleDialogOption(
            child: Text('MEMBER'),
          ),
          SimpleDialogOption(
            child: Text('STUDENT'),
          ),
        ],
      ),
    );

    if (selected == null) {
      return;
    }

    final index = _users.indexWhere(
      (item) => item.id == user.id,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      _users[index] = user.copyWith(
        role: selected,
      );
    });
  }

  Future<void> _deleteUser(
    AdminPerson user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceElevated,
        title: const Text(
          'Delete user?',
        ),
        content: Text(
          'Soft-delete ${user.name} from the active users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _users.removeWhere(
        (item) => item.id == user.id,
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(
                  alpha: 0.13,
                )
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(
            AppDimens.radiusFull,
          ),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            selected ? AppColors.secondary : AppColors.darkTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final AdminPerson user;
  final VoidCallback onChangeRole;
  final VoidCallback onDelete;

  const _PersonCard({
    required this.user,
    required this.onChangeRole,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: AppTextStyles.labelLarge(
                  Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.titleMedium(
                    AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall(
                    AppColors.darkTextTertiary,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  user.role,
                  style: AppTextStyles.labelSmall(
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.darkSurfaceElevated,
            onSelected: (value) {
              if (value == 'role') {
                onChangeRole();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'role',
                child: Text(
                  'Change role',
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete user',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
