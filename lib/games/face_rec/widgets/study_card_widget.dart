import 'package:flutter/material.dart';
import '../models/person_profile.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'real_person_avatar.dart';

class StudyCardWidget extends StatelessWidget {
  final PersonProfile profile;
  final VoidCallback onProceed;
  final String instructionMessage;
  final bool isHardLevel;
  final int currentTrialIndex;
  final int totalTrials;
  final VoidCallback? onBack;

  const StudyCardWidget({
    super.key,
    required this.profile,
    required this.onProceed,
    this.instructionMessage = "Take your time to study this narrative.",
    this.isHardLevel = false,
    this.currentTrialIndex = 0,
    this.totalTrials = 4,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = isHardLevel ? profile.descriptionOnly : profile.fullNarrative;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            // TOP NAVIGATION & PROGRESS BAR SECTION (Screenshot 2 Spec)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  // Nav Controls Bar: Back button, Category Pill, Spacer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button (48x48px white circle)
                      InkWell(
                        onTap: () {
                          if (onBack != null) {
                            onBack!();
                          } else if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.colorBorderGray),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colorPrimary.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.colorPrimary,
                            size: 24,
                          ),
                        ),
                      ),

                      // Category Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppTheme.colorBorderGray),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.colorPrimary.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          "FAMILIAR FACES",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.colorPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48), // Balance spacing
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Round Progress Indicator Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Trial ${currentTrialIndex + 1} / $totalTrials",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.colorPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(totalTrials, (index) {
                            final bool isActive = index <= currentTrialIndex;
                            return Expanded(
                              child: Container(
                                height: 8,
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 0 : 3,
                                  right: index == totalTrials - 1 ? 0 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.colorSoftBlue
                                      : AppTheme.colorBorderGray.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT AREA (Scrollable Study Card)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Primary Instruction Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.colorPrimary.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            isHardLevel ? "Read and remember" : "Look carefully and remember",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.colorPrimary,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHardLevel
                                ? "Take your time to study this description."
                                : instructionMessage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.colorPrimary.withValues(alpha: 0.75),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Framed Target Study Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.colorBorderGray),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.colorPrimary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Photo Frame: Shown in Easy/Medium; Hidden in Hard level
                          if (!isHardLevel) ...[
                            RealPersonAvatar(
                              photoUrl: profile.photoUrl,
                              localImagePath: profile.localImagePath,
                              personName: profile.name,
                              isCircular: false,
                              aspectRatio: 4 / 3,
                            ),
                            const SizedBox(height: 14),

                            // Name & Relationship Tag Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.colorPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.colorSoftBlue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppTheme.colorSoftBlue.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    profile.relationship.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.colorPrimary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            // Hard Level Icon Header
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.colorSoftBlue.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.description_rounded,
                                  size: 40,
                                  color: AppTheme.colorPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Target Description",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colorPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Narrative Text Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.colorBackground.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              "\"$displayText\"",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.colorPrimary.withValues(alpha: 0.85),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Listen Narrative Button
                          Material(
                            color: AppTheme.colorSoftBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              onTap: () {
                                final textToSpeak = isHardLevel
                                    ? "Target description: $displayText"
                                    : "${profile.name}. Relationship: ${profile.relationship}. $displayText";
                                TTSService().speak(textToSpeak);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppTheme.colorSoftBlue.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.volume_up_rounded,
                                      color: AppTheme.colorPrimary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Listen Narrative",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.colorPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // BOTTOM ACTION AREA (Sticky Footer Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    TTSService().stop();
                    onProceed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colorPrimary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: AppTheme.colorPrimary.withValues(alpha: 0.35),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "I'm Ready — Begin Trial",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
