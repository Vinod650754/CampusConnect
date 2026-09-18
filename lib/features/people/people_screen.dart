import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'people_controller.dart';
import 'people_models.dart';
import 'people_repository.dart';
import '../auth/auth_controller.dart';

class PeopleScreen extends StatefulWidget {
  final bool embedded;

  const PeopleScreen({super.key, this.embedded = false});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late final PeopleController controller;

  PeopleController _controller() {
    if (Get.isRegistered<PeopleController>()) {
      return Get.find<PeopleController>();
    }

    final controller = Get.put(
      PeopleController(
        repository: PeopleRepository(
          apiClient: Get.find<ApiClient>(),
        ),
      ),
    );

    return controller;
  }

  @override
  void initState() {
    super.initState();

    final alreadyRegistered = Get.isRegistered<PeopleController>();
    controller = _controller();

    // The controller is shared by GetX. If it already existed, refresh when
    // the People tab is entered again so the list reflects current backend data.
    if (alreadyRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.refreshUsers();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        const _PeopleBackground(),
        Column(
          children: [
            _PeopleHeader(controller: controller, showBack: !widget.embedded),
            Expanded(
              child: _PeopleBody(controller: controller),
            ),
          ],
        ),
      ],
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: SafeArea(child: body),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// HEADER
// ═════════════════════════════════════════════════════════════════

class _PeopleHeader extends StatelessWidget {
  final PeopleController controller;
  final bool showBack;

  const _PeopleHeader({
    required this.controller,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              if (showBack) ...[
                _BackButton(
                  onTap: () { Get.back(); },
                ),
                const SizedBox(width: 12),
              ],
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PEOPLE',
                      style: TextStyle(
                        color: Color(0xFFF4F4F7),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Users, roles & access',
                      style: TextStyle(
                        color: Color(0xFF6C6C75),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => _HeaderCount(
                  count: controller.totalUsers.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SearchField(controller: controller),
          const SizedBox(height: 12),
          _RoleFilters(controller: controller),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// BODY
// ═════════════════════════════════════════════════════════════════

class _PeopleBody extends StatelessWidget {
  final PeopleController controller;

  const _PeopleBody({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && !controller.hasUsers) {
        return const _LoadingState();
      }

      if (controller.errorMessage.value != null && !controller.hasUsers) {
        return _ErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.loadUsers,
        );
      }

      if (controller.isEmpty) {
        return _EmptyState(
          hasFilters: controller.hasActiveFilters,
          onClear: controller.clearFilters,
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF8B7DFF),
        backgroundColor: const Color(0xFF111116),
        onRefresh: controller.refreshUsers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _OverviewStrip(controller: controller),
            const SizedBox(height: 16),
            ...List.generate(
              controller.users.length,
              (index) {
                final user = controller.users[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UserCard(
                    user: user,
                    onTap: () async {
                      await _showUserDetails(
                        context,
                        controller,
                        user,
                      );
                    },
                  ),
                );
              },
            ),
            if (controller.hasMorePages)
              _LoadMoreButton(controller: controller),
            if (controller.isLoadingMore.value)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF8B7DFF),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ═════════════════════════════════════════════════════════════════
// SEARCH
// ═════════════════════════════════════════════════════════════════

class _SearchField extends StatefulWidget {
  final PeopleController controller;

  const _SearchField({
    required this.controller,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.controller.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF25252D),
        ),
      ),
      child: TextField(
        controller: _textController,
        onChanged: widget.controller.search,
        style: const TextStyle(
          color: Color(0xFFEDEDF2),
          fontSize: 13,
        ),
        cursorColor: const Color(0xFF8B7DFF),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search name, email or user...',
          hintStyle: const TextStyle(
            color: Color(0xFF5E5E67),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF777780),
            size: 21,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (_, value, __) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: () {
                  _textController.clear();
                  widget.controller.search('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF707078),
                  size: 18,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// ROLE FILTERS
// ═════════════════════════════════════════════════════════════════

class _RoleFilters extends StatelessWidget {
  final PeopleController controller;

  const _RoleFilters({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const roles = <String>[
      'ALL',
      'SUPER_ADMIN',
      'ADMIN',
      'CORE_TEAM',
      'MEMBER',
      'STUDENT',
    ];

    return SizedBox(
      height: 34,
      child: Obx(() {
        // Read the observable directly inside Obx.
        // This ensures GetX properly tracks the dependency.
        final selectedRole = controller.selectedRole.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: roles.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (_, index) {
            final role = roles[index];

            final selected =
                role == 'ALL' ? selectedRole == null : selectedRole == role;

            return GestureDetector(
              onTap: () {
                controller.setRoleFilter(
                  role == 'ALL' ? null : role,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6D5DF6).withValues(alpha: 0.14)
                      : const Color(0xFF0D0D11),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6D5DF6).withValues(alpha: 0.48)
                        : const Color(0xFF232329),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _roleLabel(role),
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFB7AFFF)
                        : const Color(0xFF74747D),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return 'SUPER ADMIN';
      case 'CORE_TEAM':
        return 'CORE TEAM';
      case 'ALL':
        return 'ALL';
      default:
        return role;
    }
  }
}

// ═════════════════════════════════════════════════════════════════
// OVERVIEW STRIP
// ═════════════════════════════════════════════════════════════════

class _OverviewStrip extends StatelessWidget {
  final PeopleController controller;

  const _OverviewStrip({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.people_alt_outlined,
            label: 'VISIBLE',
            value: '${controller.users.length}',
            accent: const Color(0xFF8B7DFF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.verified_user_outlined,
            label: 'ACTIVE',
            value: '${controller.users.where((u) => u.isActive).length}',
            accent: const Color(0xFF22C7C1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.filter_alt_outlined,
            label: 'FILTER',
            value: controller.hasActiveFilters ? 'ON' : 'OFF',
            accent: const Color(0xFFE9A84B),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// USER CARD
// ═════════════════════════════════════════════════════════════════

class _UserCard extends StatelessWidget {
  final PeopleUser user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.primaryRole ?? 'UNKNOWN';
    final roleColor = _roleColor(role);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C10),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFF23232A),
            ),
          ),
          child: Row(
            children: [
              _Avatar(
                user: user,
                color: roleColor,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? 'Unnamed user' : user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFECECF1),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF66666F),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RoleBadge(
                          role: role,
                          color: roleColor,
                        ),
                        const SizedBox(width: 7),
                        _StatusDot(
                          active: user.isActive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF55555E),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return const Color(0xFF8B7DFF);
      case 'ADMIN':
        return const Color(0xFF22C7C1);
      case 'CORE_TEAM':
        return const Color(0xFFE9A84B);
      case 'MEMBER':
        return const Color(0xFF5E9EFF);
      case 'STUDENT':
        return const Color(0xFF9B9BA5);
      default:
        return const Color(0xFF777780);
    }
  }
}

// ═════════════════════════════════════════════════════════════════
// AVATAR
// ═════════════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final PeopleUser user;
  final Color color;

  const _Avatar({
    required this.user,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.trim().isEmpty
        ? '?'
        : user.fullName.trim()[0].toUpperCase();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.32),
        ),
      ),
      child: user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// ROLE BADGE
// ═════════════════════════════════════════════════════════════════

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;

  const _RoleBadge({
    required this.role,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _label(role),
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
    );
  }

  String _label(String value) {
    switch (value) {
      case 'SUPER_ADMIN':
        return 'SUPER ADMIN';
      case 'CORE_TEAM':
        return 'CORE TEAM';
      default:
        return value;
    }
  }
}

// ═════════════════════════════════════════════════════════════════
// STATUS
// ═════════════════════════════════════════════════════════════════

class _StatusDot extends StatelessWidget {
  final bool active;

  const _StatusDot({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF22C7C1) : const Color(0xFF777780);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          active ? 'ACTIVE' : 'INACTIVE',
          style: TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.45,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// LOAD MORE
// ═════════════════════════════════════════════════════════════════

class _LoadMoreButton extends StatelessWidget {
  final PeopleController controller;

  const _LoadMoreButton({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: controller.loadMore,
        child: const Text(
          'LOAD MORE PEOPLE',
          style: TextStyle(
            color: Color(0xFF9B8FFF),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// USER DETAILS
// ═════════════════════════════════════════════════════════════════

Future<void> _showUserDetails(
  BuildContext context,
  PeopleController controller,
  PeopleUser user,
) async {
  final details = await controller.loadUserDetails(user.id);
  if (!context.mounted || details == null) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UserDetailsSheet(
      controller: controller,
      user: details,
    ),
  );
}

class _UserDetailsSheet extends StatelessWidget {
  final PeopleController controller;
  final PeopleUser user;

  const _UserDetailsSheet({
    required this.controller,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final currentRole = auth.role ?? '';
    final canManageRole = currentRole == 'SUPER_ADMIN'
        ? user.id != auth.user?.id
        : currentRole == 'ADMIN'
            ? user.id != auth.user?.id && user.primaryRole != 'SUPER_ADMIN'
            : false;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 720,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0F),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF383840),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _Avatar(
                    user: user,
                    color: const Color(0xFF8B7DFF),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Color(0xFFF0F0F4),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Color(0xFF707079),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _DetailsSection(
                title: 'ACCOUNT',
                children: [
                  _DetailRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Status',
                    value: user.status,
                  ),
                  _DetailRow(
                    icon: Icons.mark_email_read_outlined,
                    label: 'Email verified',
                    value: user.isEmailVerified ? 'Verified' : 'Not verified',
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Joined',
                    value: _formatDate(user.createdAt),
                  ),
                  _DetailRow(
                    icon: Icons.login_outlined,
                    label: 'Last login',
                    value: user.lastLoginAt == null
                        ? 'Never'
                        : _formatDate(user.lastLoginAt!),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailsSection(
                title: 'PROFILE',
                children: [
                  if (user.phone != null && user.phone!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phone!,
                    ),
                  if (user.rollNumber != null && user.rollNumber!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Roll number',
                      value: user.rollNumber!,
                    ),
                  if (user.department != null && user.department!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.account_tree_outlined,
                      label: 'Department',
                      value: user.department!,
                    ),
                  if (user.yearOfStudy != null)
                    _DetailRow(
                      icon: Icons.school_outlined,
                      label: 'Year',
                      value: '${user.yearOfStudy}',
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailsSection(
                title: 'ATTENDANCE',
                children: [
                  _DetailRow(
                    icon: Icons.fact_check_outlined,
                    label: 'Events attended',
                    value: '${user.eventsAttended} / ${user.totalEvents}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailsSection(
                title: 'ROLES',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.roles
                        .map(
                          (assignment) => _ManagementRoleChip(
                            role: assignment.role.name,
                            onRemove: canManageRole
                                ? () {
                                    _confirmRemoveRole(
                                      context,
                                      controller,
                                      user,
                                      assignment.role.name,
                                    );
                                  }
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  if (canManageRole) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showAddRoleDialog(
                          context,
                          controller,
                          user,
                        );
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 17),
                      label: const Text('CHANGE ROLE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9B8FFF),
                        side: const BorderSide(color: Color(0xFF39334F)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
              if (canManageRole) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmDelete(
                        context,
                        controller,
                        user,
                      );
                    },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'DELETE USER',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE56B78),
                    side: BorderSide(
                      color: const Color(0xFFE56B78).withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// ADD ROLE
// ═════════════════════════════════════════════════════════════════

void _showAddRoleDialog(
  BuildContext context,
  PeopleController controller,
  PeopleUser user,
) {
  final currentRole = Get.find<AuthController>().role ?? '';
  final available = PeopleController.availableRoles
      .where((role) => !user.hasRole(role))
      .where((role) => currentRole != 'ADMIN' || role != 'SUPER_ADMIN')
      .toList();

  if (available.isEmpty) {
    Get.snackbar(
      'No roles available',
      'This user already has every available role.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF15151B),
      colorText: const Color(0xFFEDEDF2),
    );
    return;
  }

  Get.dialog(
    Dialog(
      backgroundColor: const Color(0xFF111116),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHANGE ROLE',
              style: TextStyle(
                color: Color(0xFFF0F0F4),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose the new role for ${user.fullName}.',
              style: const TextStyle(
                color: Color(0xFF6D6D76),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 18),
            ...available.map(
              (role) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _prettyRole(role),
                  style: const TextStyle(
                    color: Color(0xFFE5E5EA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFF8B7DFF),
                  size: 20,
                ),
                onTap: () async {
                  Get.back();

                  final success = await controller.addRole(
                    userId: user.id,
                    role: role,
                  );

                  if (success) {
                    Get.snackbar(
                      'Role assigned',
                      '${_prettyRole(role)} added successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF11151A),
                      colorText: const Color(0xFFEDEDF2),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════
// REMOVE ROLE
// ═════════════════════════════════════════════════════════════════

void _confirmRemoveRole(
  BuildContext context,
  PeopleController controller,
  PeopleUser user,
  String role,
) {
  if (user.roles.length <= 1) {
    Get.snackbar(
      'Cannot remove role',
      'A user must have at least one role.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF15151B),
      colorText: const Color(0xFFEDEDF2),
    );
    return;
  }

  Get.dialog(
    AlertDialog(
      backgroundColor: const Color(0xFF111116),
      title: const Text(
        'Remove role?',
        style: TextStyle(
          color: Color(0xFFF0F0F4),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Remove ${_prettyRole(role)} from ${user.fullName}?',
        style: const TextStyle(
          color: Color(0xFF777780),
          fontSize: 12,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text(
            'CANCEL',
            style: TextStyle(
              color: Color(0xFF777780),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();

            final success = await controller.removeRole(
              userId: user.id,
              role: role,
            );

            if (success) {
              Get.snackbar(
                'Role removed',
                '${_prettyRole(role)} removed.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF11151A),
                colorText: const Color(0xFFEDEDF2),
              );
            }
          },
          child: const Text(
            'REMOVE',
            style: TextStyle(
              color: Color(0xFFE56B78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════
// DELETE
// ═════════════════════════════════════════════════════════════════

void _confirmDelete(
  BuildContext context,
  PeopleController controller,
  PeopleUser user,
) {
  Get.dialog(
    AlertDialog(
      backgroundColor: const Color(0xFF111116),
      title: const Text(
        'Delete user?',
        style: TextStyle(
          color: Color(0xFFF0F0F4),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'This will remove ${user.fullName} from the active People list.',
        style: const TextStyle(
          color: Color(0xFF777780),
          fontSize: 12,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text(
            'CANCEL',
            style: TextStyle(
              color: Color(0xFF777780),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();

            final success = await controller.deleteUser(user.id);

            if (success) {
              Get.back();

              Get.snackbar(
                'User deleted',
                '${user.fullName} has been removed.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF11151A),
                colorText: const Color(0xFFEDEDF2),
              );
            }
          },
          child: const Text(
            'DELETE',
            style: TextStyle(
              color: Color(0xFFE56B78),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════
// DETAILS HELPERS
// ═════════════════════════════════════════════════════════════════

class _DetailsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF22222A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF686871),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF676770),
            size: 17,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF696972),
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFDCDCE2),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementRoleChip extends StatelessWidget {
  final String role;
  final VoidCallback? onRemove;

  const _ManagementRoleChip({
    required this.role,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 9,
        right: 4,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF17151F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFF373143),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _prettyRole(role),
            style: const TextStyle(
              color: Color(0xFFAAA0D9),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.close_rounded, color: Color(0xFF777080), size: 13),
              ),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// MINI STAT
// ═════════════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22222A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFEDEDF2),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF62626B),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// HEADER COUNT
// ═════════════════════════════════════════════════════════════════

class _HeaderCount extends StatelessWidget {
  final int count;

  const _HeaderCount({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6D5DF6).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF6D5DF6).withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        '$count USERS',
        style: const TextStyle(
          color: Color(0xFF9B8FFF),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// BACK BUTTON
// ═════════════════════════════════════════════════════════════════

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF25252D),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFFB9B9C2),
          size: 17,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// STATES
// ═════════════════════════════════════════════════════════════════

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF8B7DFF),
          ),
          SizedBox(height: 14),
          Text(
            'Loading people...',
            style: TextStyle(
              color: Color(0xFF686871),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyState({
    required this.hasFilters,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF6D5DF6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                color: Color(0xFF777080),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilters ? 'No matching people' : 'No people yet',
              style: const TextStyle(
                color: Color(0xFFE5E5EA),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasFilters
                  ? 'Try changing your search or role filter.'
                  : 'Users registered on Campus Connect will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF686871),
                fontSize: 10,
                height: 1.5,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClear,
                child: const Text(
                  'CLEAR FILTERS',
                  style: TextStyle(
                    color: Color(0xFF9B8FFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF777780),
              size: 34,
            ),
            const SizedBox(height: 14),
            const Text(
              'Could not load people',
              style: TextStyle(
                color: Color(0xFFE5E5EA),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF686871),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'TRY AGAIN',
                style: TextStyle(
                  color: Color(0xFF9B8FFF),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// BACKGROUND
// ═════════════════════════════════════════════════════════════════

class _PeopleBackground extends StatelessWidget {
  const _PeopleBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -160,
            child: _glow(
              const Color(0xFF6D5DF6),
              360,
            ),
          ),
          Positioned(
            bottom: -250,
            left: -190,
            child: _glow(
              const Color(0xFF22C7C1),
              430,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.045),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════

String _prettyRole(String role) {
  switch (role) {
    case 'SUPER_ADMIN':
      return 'SUPER ADMIN';
    case 'CORE_TEAM':
      return 'CORE TEAM';
    default:
      return role;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
}
