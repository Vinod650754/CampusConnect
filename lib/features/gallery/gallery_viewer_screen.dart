import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'gallery_model.dart';

class GalleryViewerScreen extends StatelessWidget {
  final GalleryImageModel image;

  const GalleryViewerScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          image.eventTitle ?? 'Gallery',
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(
            image.imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 54,
            ),
          ),
        ),
      ),
      bottomNavigationBar: image.caption != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  image.caption!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
