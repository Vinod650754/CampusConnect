import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Circular profile avatar. Falls back to the user's initials on a brand
/// gradient when [imageUrl] is null/empty, and to a placeholder while a
/// remote image loads. Used in profile headers, member lists, leaderboards,
/// and comment/attendee rows.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final double size;
  final VoidCallback? onTap;
  final Widget? badge;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.fullName,
    this.size = 44,
    this.onTap,
    this.badge,
  });

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initialsFallback(),
                errorWidget: (_, __, ___) => _initialsFallback(),
              )
            : _initialsFallback(),
      ),
    );

    final stacked = badge == null
        ? avatar
        : Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(right: -2, bottom: -2, child: badge!),
            ],
          );

    if (onTap == null) return stacked;

    return GestureDetector(onTap: onTap, child: stacked);
  }

  Widget _initialsFallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.labelLarge(Colors.white).copyWith(fontSize: size * 0.38),
      ),
    );
  }
}
