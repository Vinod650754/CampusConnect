import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'gallery_controller.dart';
import 'gallery_model.dart';
import 'gallery_upload_screen.dart';
import 'gallery_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const GalleryScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final GalleryController controller;

  bool get canUpload =>
      widget.role == 'SUPER_ADMIN' ||
      widget.role == 'ADMIN' ||
      widget.role == 'CORE_TEAM';

  bool get canDelete => widget.role == 'SUPER_ADMIN' || widget.role == 'ADMIN';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<GalleryController>()
        ? Get.find<GalleryController>()
        : Get.put(
            GalleryController(),
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
        AppShellDestination(
          label: 'Dashboard',
          icon: Icons.grid_view_outlined,
          activeIcon: Icons.grid_view_rounded,
        ),
        AppShellDestination(
          label: 'Events',
          icon: Icons.event_outlined,
          activeIcon: Icons.event_rounded,
        ),
        AppShellDestination(
          label: 'Gallery',
          icon: Icons.photo_library_outlined,
          activeIcon: Icons.photo_library_rounded,
        ),
        AppShellDestination(
          label: 'Updates',
          icon: Icons.campaign_outlined,
          activeIcon: Icons.campaign_rounded,
        ),
      ],
      selectedIndex: 2,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(
      () {
        final images = controller.filteredImages;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: DashboardHeader(
                    eyebrow: 'Campus memories',
                    title: 'Gallery',
                    subtitle:
                        'Explore moments captured across CampusConnect events and activities.',
                  ),
                ),
                if (canUpload)
                  FilledButton.icon(
                    onPressed: () {
                      Get.to(
                        () => GalleryUploadScreen(
                          controller: controller,
                          role: widget.role,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                    ),
                    label: const Text(
                      'Add image',
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: AppDimens.space20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.setSearch,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                      ),
                      hintText: 'Search gallery...',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                _filterButton(),
              ],
            ),
            const SizedBox(
              height: AppDimens.space20,
            ),
            Expanded(
              child: images.isEmpty
                  ? const DashboardEmptyCard(
                      icon: Icons.photo_library_outlined,
                      title: 'No images found',
                      description: 'Try another search or event filter.',
                    )
                  : _buildGrid(
                      images,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterButton() {
    return PopupMenuButton<String?>(
      color: AppColors.darkSurfaceElevated,
      onSelected: (eventId) {
        controller.setEventFilter(
          eventId,
        );
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('All events'),
        ),
        ...controller.eventNames.map(
          (name) => PopupMenuItem<String?>(
            value: controller.images
                .firstWhere(
                  (image) => image.eventTitle == name,
                )
                .eventId,
            child: Text(name),
          ),
        ),
      ],
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(
            AppDimens.radiusMedium,
          ),
          border: Border.all(
            color: AppColors.darkBorder,
          ),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildGrid(
    List<GalleryImageModel> images,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
                ? 3
                : constraints.maxWidth >= 450
                    ? 2
                    : 1;

        return GridView.builder(
          padding: const EdgeInsets.only(
            bottom: 30,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: images.length,
          itemBuilder: (_, index) {
            final image = images[index];

            return _GalleryCard(
              image: image,
              canDelete: canDelete,
              onTap: () {
                Get.to(
                  () => GalleryViewerScreen(
                    image: image,
                  ),
                );
              },
              onDelete: canDelete
                  ? () {
                      controller.deleteImage(
                        image.id,
                      );
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryImageModel image;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _GalleryCard({
    required this.image,
    required this.canDelete,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusLarge,
            ),
            border: Border.all(
              color: AppColors.darkBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(
                      AppDimens.radiusLarge,
                    ),
                  ),
                  child: Image.network(
                    image.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkSurfaceElevated,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (image.eventTitle != null)
                            Text(
                              image.eventTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSmall(
                                AppColors.secondary,
                              ),
                            ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            image.caption ?? 'CampusConnect memory',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall(
                              AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
