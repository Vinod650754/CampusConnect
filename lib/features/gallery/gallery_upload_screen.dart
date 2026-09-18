import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'gallery_controller.dart';
import 'gallery_model.dart';

class GalleryUploadScreen extends StatefulWidget {
  final GalleryController controller;
  final String role;

  const GalleryUploadScreen({
    super.key,
    required this.controller,
    required this.role,
  });

  @override
  State<GalleryUploadScreen> createState() => _GalleryUploadScreenState();
}

class _GalleryUploadScreenState extends State<GalleryUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _urlController = TextEditingController();

  final _captionController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Add gallery image',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            20,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(
                20,
              ),
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
                children: [
                  TextFormField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'https://...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Image URL is required';
                      }

                      final uri = Uri.tryParse(
                        value.trim(),
                      );

                      if (uri == null || !uri.hasScheme) {
                        return 'Enter a valid image URL';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Caption',
                      hintText: 'Describe this moment...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                      ),
                      label: const Text(
                        'Add image',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final image = GalleryImageModel(
      id: 'gallery-${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: _urlController.text.trim(),
      caption: _captionController.text.trim(),
      eventId: null,
      eventTitle: null,
      uploadedBy: 'current-user',
      uploaderName: widget.role,
      createdAt: DateTime.now(),
    );

    widget.controller.addImage(
      image,
    );

    Get.back();
  }
}
