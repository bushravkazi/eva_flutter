import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyConsentBanner extends StatelessWidget {
  final bool compact;
  const PrivacyConsentBanner({super.key, this.compact = true});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.colorSurfaceLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colorPrimary.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.colorSecondary, size: 20),
            SizedBox(width: 8),
            Text(
              "Privacy-Safe Memory Support Activity",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.colorTextPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.colorBorderGray),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: AppTheme.colorSecondary, size: 28),
              SizedBox(width: 10),
              Text(
                "Privacy & Framing Commitment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colorTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "• Framing Guardrail: Designed as a cognitive stimulation & memory support activity — NOT a diagnostic test.",
            style: TextStyle(fontSize: 14, height: 1.4, color: AppTheme.colorTextSecondary),
          ),
          SizedBox(height: 4),
          Text(
            "• Local-First Privacy: All personal photos and notes remain securely stored on your local device.",
            style: TextStyle(fontSize: 14, height: 1.4, color: AppTheme.colorTextSecondary),
          ),
        ],
      ),
    );
  }
}
