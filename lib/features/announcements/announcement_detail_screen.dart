import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'announcement_model.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: const Text('Announcement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.space20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.campaign_rounded, color: AppColors.secondary, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text(announcement.audienceLabel, style: AppTextStyles.labelSmall(AppColors.secondary))),
              ]),
              const SizedBox(height: 18),
              Text(announcement.title, style: AppTextStyles.displaySmall(AppColors.darkTextPrimary)),
              const SizedBox(height: 14),
              Text(announcement.content, style: AppTextStyles.bodyLarge(AppColors.darkTextSecondary)),
              const SizedBox(height: 20),
              Text('Published by ${announcement.authorName}', style: AppTextStyles.labelSmall(AppColors.darkTextTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
