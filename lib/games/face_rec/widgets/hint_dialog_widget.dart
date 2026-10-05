import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class HintDialogWidget extends StatelessWidget {
  final String relationshipHint;
  final VoidCallback onClose;

  const HintDialogWidget({
    super.key,
    required this.relationshipHint,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final hintMessage = "This person is a $relationshipHint";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Yellow Lightbulb Circle
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppTheme.colorButterYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppTheme.colorPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            const Text(
              "Context Hint",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Hint Text Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.colorBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.colorSelectedBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.group_rounded,
                      color: AppTheme.colorPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hintMessage,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colorTextPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Listen Hint Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  TTSService().speak(hintMessage);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorSecondaryFixed,
                  foregroundColor: AppTheme.colorPrimary,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: AppTheme.colorSoftBlue.withValues(alpha: 0.4),
                  ),
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                label: const Text(
                  "Listen Hint",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Got It — Resume Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorPrimary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.check_rounded, size: 22),
                label: const Text(
                  "Got It — Resume",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
