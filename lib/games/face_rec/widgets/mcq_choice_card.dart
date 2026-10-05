import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MCQChoiceCard extends StatefulWidget {
  final String optionText;
  final bool isSelected;
  final bool isWrong;
  final bool isCorrect;
  final VoidCallback onTap;
  final String labelPrefix; // e.g. "A", "B", "C", "D"

  const MCQChoiceCard({
    super.key,
    required this.optionText,
    required this.isSelected,
    required this.isWrong,
    required this.isCorrect,
    required this.onTap,
    required this.labelPrefix,
  });

  @override
  State<MCQChoiceCard> createState() => _MCQChoiceCardState();
}

class _MCQChoiceCardState extends State<MCQChoiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant MCQChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWrong && !oldWidget.isWrong) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.colorBorderGray;
    Color bgColor = AppTheme.colorCardBg;
    Color textColor = AppTheme.colorPrimary;
    Color badgeBgColor = AppTheme.colorSurface;
    Color badgeTextColor = AppTheme.colorPrimary;
    String badgeText = widget.labelPrefix;
    Widget trailingIcon = const SizedBox.shrink();

    if (widget.isCorrect) {
      borderColor = AppTheme.colorPrimary;
      bgColor = AppTheme.colorSelectedBg;
      textColor = AppTheme.colorPrimary;
      badgeBgColor = AppTheme.colorPrimary;
      badgeTextColor = Colors.white;
      badgeText = '✓';
      trailingIcon = const Icon(
        Icons.check_circle_rounded,
        color: AppTheme.colorPrimary,
        size: 28,
      );
    } else if (widget.isSelected && !widget.isWrong) {
      borderColor = AppTheme.colorPrimary;
      bgColor = AppTheme.colorSelectedBg;
      textColor = AppTheme.colorPrimary;
      badgeBgColor = AppTheme.colorPrimary;
      badgeTextColor = Colors.white;
    } else if (widget.isWrong) {
      borderColor = AppTheme.colorError;
      bgColor = AppTheme.colorErrorContainer;
      textColor = AppTheme.colorError;
      badgeBgColor = AppTheme.colorError;
      badgeTextColor = Colors.white;
      badgeText = '✕';
      trailingIcon = const Icon(
        Icons.close_rounded,
        color: AppTheme.colorError,
        size: 28,
      );
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset = sin(_shakeController.value * pi * 4) * 8.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: (widget.isCorrect || widget.isSelected) ? 2.0 : 1.0,
                ),
                boxShadow: [
                  if (!widget.isWrong)
                    BoxShadow(
                      color: AppTheme.colorPrimary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Circle Badge A, B, C, D
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.optionText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: (widget.isCorrect || widget.isSelected)
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  trailingIcon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
