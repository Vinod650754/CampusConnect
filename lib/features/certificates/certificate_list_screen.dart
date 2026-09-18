import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'certificate_controller.dart';
import 'certificate_detail_screen.dart';
import 'certificate_issue_screen.dart';
import 'certificate_model.dart';

class CertificateListScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const CertificateListScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<CertificateListScreen> createState() => _CertificateListScreenState();
}

class _CertificateListScreenState extends State<CertificateListScreen> {
  late final CertificateController controller;

  bool get canManage => widget.role == 'ADMIN' || widget.role == 'SUPER_ADMIN';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<CertificateController>()
        ? Get.find<CertificateController>()
        : Get.put(
            CertificateController(),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }

    return AppShell(
      roleLabel: widget.role,
      destinations: const [
        AppShellDestination(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
        AppShellDestination(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded),
        AppShellDestination(label: 'Certificates', icon: Icons.workspace_premium_outlined, activeIcon: Icons.workspace_premium_rounded),
        AppShellDestination(label: 'Updates', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded),
      ],
      selectedIndex: 2,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: DashboardHeader(
                  eyebrow: 'Achievements',
                  title: 'Certificates',
                  subtitle: 'View participation certificates and keep your achievements in one place.',
                ),
              ),
              if (canManage)
                FilledButton.icon(
                  onPressed: () => Get.to(() => CertificateIssueScreen(controller: controller)),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Issue'),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          Expanded(
            child: controller.certificates.isEmpty
                ? const DashboardEmptyCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'No certificates',
                    description: 'Certificates issued to you will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 30),
                    itemCount: controller.certificates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = controller.certificates[index];
                      return _CertificateCard(
                        certificate: item,
                        onTap: () => Get.to(
                          () => CertificateDetailScreen(
                            certificate: item,
                            canRevoke: canManage,
                            onRevoke: canManage ? () => controller.revokeCertificate(item.id) : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final VoidCallback onTap;

  const _CertificateCard({
    required this.certificate,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final valid = certificate.isValid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        child: Ink(
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusLarge,
            ),
            border: Border.all(
              color: valid
                  ? AppColors.secondary.withValues(
                      alpha: 0.22,
                    )
                  : AppColors.darkBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    17,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title,
                      style: AppTextStyles.titleMedium(
                        AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      certificate.eventTitle ?? 'CampusConnect',
                      style: AppTextStyles.bodySmall(
                        AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        certificate.issuedAt,
                      ),
                      style: AppTextStyles.labelSmall(
                        AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                valid ? Icons.verified_rounded : Icons.block_rounded,
                color: valid ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
