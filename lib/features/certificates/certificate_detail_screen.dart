import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'certificate_model.dart';

class CertificateDetailScreen extends StatelessWidget {
  final CertificateModel certificate;
  final bool canRevoke;
  final VoidCallback? onRevoke;

  const CertificateDetailScreen({
    super.key,
    required this.certificate,
    required this.canRevoke,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final valid = certificate.isValid;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Certificate',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                28,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text(
                    'CERTIFICATE OF PARTICIPATION',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall(
                      Colors.white.withValues(
                        alpha: 0.78,
                      ),
                    ).copyWith(
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    certificate.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall(
                      Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    certificate.eventTitle ?? 'CampusConnect Event',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge(
                      Colors.white.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: AppColors.darkBorder,
                ),
              ),
              child: Column(
                children: [
                  _info(
                    'Recipient',
                    certificate.userName,
                  ),
                  _divider(),
                  _info(
                    'Status',
                    valid ? 'Issued / Valid' : 'Revoked',
                    color: valid ? AppColors.success : AppColors.error,
                  ),
                  _divider(),
                  _info(
                    'Verification hash',
                    certificate.certificateHash ?? 'Not available',
                  ),
                ],
              ),
            ),
            if (canRevoke && valid) ...[
              const SizedBox(
                height: 18,
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onRevoke,
                  icon: const Icon(
                    Icons.block_outlined,
                  ),
                  label: const Text(
                    'Revoke certificate',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(
            AppColors.darkTextTertiary,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SelectableText(
          value,
          style: AppTextStyles.bodyMedium(
            color ?? AppColors.darkTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(
      height: 26,
      color: AppColors.darkBorder,
    );
  }
}
