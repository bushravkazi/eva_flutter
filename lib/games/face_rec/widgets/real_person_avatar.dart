import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RealPersonAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? localImagePath;
  final String personName;
  final double size;
  final bool isCircular;
  final double aspectRatio;

  const RealPersonAvatar({
    super.key,
    this.photoUrl,
    this.localImagePath,
    required this.personName,
    this.size = 140,
    this.isCircular = true,
    this.aspectRatio = 4 / 3,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final file = File(localImagePath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }

    if (imageProvider == null && photoUrl != null && photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl!);
    }

    final Widget content = imageProvider != null
        ? Image(
            image: imageProvider,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingState(loadingProgress);
            },
          )
        : _buildPlaceholder();

    if (isCircular) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.colorBorderGray, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colorPrimary.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(child: content),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.colorBorderGray, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colorPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ImageChunkEvent progress) {
    final double? percent = progress.expectedTotalBytes != null
        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
        : null;
    return Container(
      color: AppTheme.colorSurfaceLow,
      child: Center(
        child: CircularProgressIndicator(
          value: percent,
          color: AppTheme.colorPrimary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initial = personName.isNotEmpty ? personName[0].toUpperCase() : '?';
    return Container(
      color: AppTheme.colorSurfaceLow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_rounded, size: 48, color: AppTheme.colorPrimary),
            const SizedBox(height: 4),
            Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.colorTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
