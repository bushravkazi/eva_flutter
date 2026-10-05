import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/person_profile.dart';
import '../models/performance_data.dart';
import '../models/adaptive_response.dart';
import '../services/adaptive_engine.dart';
import '../services/analytics_service.dart';
import '../services/profile_repository.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hint_dialog_widget.dart';
import '../widgets/mcq_choice_card.dart';
import '../widgets/privacy_consent_banner.dart';
import '../widgets/real_person_avatar.dart';
import '../widgets/study_card_widget.dart';
import 'caregiver_dashboard.dart';
import 'sync_screen.dart';

enum GamePhase { study, question }

class GameScreen extends StatefulWidget {
  final Function(PerformanceData data, AdaptiveResponse response)? onGameCompleted;
  final bool useCaregiverData;
  final String? selectedDifficulty;

  const GameScreen({
    super.key,
    this.onGameCompleted,
    this.useCaregiverData = false,
    this.selectedDifficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<PersonProfile> _dataset = [];
  int _currentTrialIndex = 0;
  final int _totalTrials = 4;
  String _activeDifficulty = 'easy';

  GamePhase _phase = GamePhase.study;
  late PersonProfile _targetProfile;
  List<String> _mcqOptions = [];
  String _correctAnswer = '';
  String _questionPrompt = '';

  int _firstTryCorrectCount = 0;
  int _errorCount = 0;
  int _hintsUsed = 0;
  int _retries = 0;
  bool _isFirstAttemptForCurrentTrial = true;
  String? _selectedOption;
  String? _wrongOption;
  bool _isTransitioningLevel = false;

  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    SoundService().init();
    _setupGame();
  }

  Future<void> _setupGame() async {
    final repo = ProfileRepository();
    await repo.init();

    if (widget.useCaregiverData && repo.caregiverProfiles.isNotEmpty) {
      _dataset = repo.caregiverProfiles;
    } else {
      _dataset = repo.getAutoDataset();
    }

    final profileId = await repo.getActiveProfileId();
    if (widget.selectedDifficulty != null && widget.selectedDifficulty!.isNotEmpty) {
      _activeDifficulty = widget.selectedDifficulty!;
    } else {
      _activeDifficulty = await AdaptiveEngineService().getNextDifficulty(profileId);
    }

    if (!mounted) return;

    _stopwatch.reset();
    _stopwatch.start();

    _currentTrialIndex = 0;
    _firstTryCorrectCount = 0;
    _errorCount = 0;
    _hintsUsed = 0;
    _retries = 0;
    _isTransitioningLevel = false;

    _startNextTrial();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _startNextTrial() {
    if (_currentTrialIndex >= _totalTrials || _dataset.isEmpty) {
      _finishLevelAndProceedToNext();
      return;
    }

    _targetProfile = _dataset[_currentTrialIndex % _dataset.length];
    _isFirstAttemptForCurrentTrial = true;
    _selectedOption = null;
    _wrongOption = null;
    _phase = GamePhase.study;

    _generateMCQChoices();
    setState(() {});
  }

  void _generateMCQChoices() {
    final rand = Random();

    if (_activeDifficulty == 'easy' || _activeDifficulty == 'medium') {
      _questionPrompt = _activeDifficulty == 'easy'
          ? "Who is shown in this picture?"
          : "Recall: Who was shown in the study card earlier?";
      _correctAnswer = _targetProfile.name;

      final distractors = _dataset.where((p) => p.name != _targetProfile.name).map((p) => p.name).toList();
      distractors.shuffle(rand);

      final fallbackNames = ['Sarah Miller', 'Robert Chen', 'Maya Lin', 'David Thorne', 'Emma Vance'];
      for (var fName in fallbackNames) {
        if (distractors.length >= 3) break;
        if (!distractors.contains(fName) && fName != _targetProfile.name) distractors.add(fName);
      }

      _mcqOptions = [_correctAnswer, ...distractors.take(3)];
      _mcqOptions.shuffle(rand);
    } else {
      _questionPrompt = "Which person matches this description?\n\"${_targetProfile.descriptionOnly}\"";
      _correctAnswer = _targetProfile.name;

      final distractors = _dataset.where((p) => p.name != _targetProfile.name).map((p) => p.name).toList();
      distractors.shuffle(rand);

      final fallbackNames = ['Grandma Rose', 'Uncle Tom', 'Sana Patel', 'Neighbor Julia'];
      for (var fName in fallbackNames) {
        if (distractors.length >= 3) break;
        if (!distractors.contains(fName) && fName != _targetProfile.name) distractors.add(fName);
      }

      _mcqOptions = [_correctAnswer, ...distractors.take(3)];
      _mcqOptions.shuffle(rand);
    }
  }

  void _onOptionSelected(String option) {
    if (_selectedOption != null && _selectedOption == _correctAnswer) return;

    setState(() {
      _selectedOption = option;
    });

    if (option == _correctAnswer) {
      if (_isFirstAttemptForCurrentTrial) _firstTryCorrectCount++;
      TTSService().speak("Correct! That is ${_targetProfile.name}.");

      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() {
          _currentTrialIndex++;
          _startNextTrial();
        });
      });
    } else {
      _errorCount++;
      _retries++;
      _isFirstAttemptForCurrentTrial = false;
      _wrongOption = option;

      TTSService().speak("Not quite. Please try again!");
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongOption = null);
      });
    }
  }

  void _showHintDialog() {
    _hintsUsed++;
    showDialog(
      context: context,
      builder: (_) => HintDialogWidget(
        relationshipHint: _targetProfile.relationship,
        onClose: () => Navigator.pop(context),
      ),
    );
    setState(() {});
  }

  void _openCaregiverMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, color: AppTheme.colorPrimary, size: 28),
                    SizedBox(width: 10),
                    Text(
                      "Management & Analytics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.colorSecondaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_rounded, color: AppTheme.colorPrimary),
                  ),
                  title: const Text("Caregiver Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: const Text("Upload photo profiles, context notes & view trend summaries"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()));
                  },
                ),
                const Divider(),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.colorSecondaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.phonelink_setup_rounded, color: AppTheme.colorPrimary),
                  ),
                  title: const Text("Family Link Device Sync", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: const Text("Pair user app with 6-digit Family Link Code"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _finishLevelAndProceedToNext() async {
    _stopwatch.stop();
    setState(() => _isTransitioningLevel = true);

    await SoundService().playVictorySound();

    final profileId = await ProfileRepository().getActiveProfileId();
    final totalTimeSeconds = _stopwatch.elapsed.inSeconds;
    final accuracyFraction = double.parse((_firstTryCorrectCount / _totalTrials).toStringAsFixed(2));

    final performance = PerformanceData(
      profileId: profileId,
      gameType: "familiar_faces",
      difficultyLevel: _activeDifficulty,
      accuracy: accuracyFraction,
      errorCount: _errorCount,
      completionTime: totalTimeSeconds > 0 ? totalTimeSeconds : 1,
      hintsUsed: _hintsUsed,
      retries: _retries,
      completed: true,
    );

    final res = await AnalyticsService().sendPerformancePayload(performance);
    final adaptiveJson = res['adaptiveResponse'] as Map<String, dynamic>;
    final adaptiveResp = AdaptiveResponse.fromJson(adaptiveJson);

    if (widget.onGameCompleted != null) {
      widget.onGameCompleted!(performance, adaptiveResp);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) _setupGame();
  }

  @override
  Widget build(BuildContext context) {
    if (_dataset.isEmpty || _isTransitioningLevel) {
      return Scaffold(
        backgroundColor: AppTheme.colorBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.colorPrimary),
              const SizedBox(height: 16),
              Text(
                _isTransitioningLevel ? "Proceeding to Next Level..." : "Loading...",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
              ),
            ],
          ),
        ),
      );
    }

    // STUDY PHASE VIEW (Screenshot 2 Spec)
    if (_phase == GamePhase.study) {
      return StudyCardWidget(
        profile: _targetProfile,
        isHardLevel: _activeDifficulty == 'hard',
        currentTrialIndex: _currentTrialIndex,
        totalTrials: _totalTrials,
        onBack: _openCaregiverMenu,
        onProceed: () {
          setState(() {
            _phase = GamePhase.question;
          });
          TTSService().speak(_questionPrompt);
        },
      );
    }

    // QUESTION PHASE VIEW (Screenshot 1 Spec)
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // TOP HEADER SECTION (Screenshot 1 Spec)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back / Menu Button (48x48px circle)
                      InkWell(
                        onTap: _openCaregiverMenu,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.colorSurfaceLow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colorPrimary.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.colorPrimary,
                            size: 24,
                          ),
                        ),
                      ),

                      // Reassuring Title Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.colorSecondaryFixed,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.colorPrimary.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.face_rounded,
                              color: AppTheme.colorPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Familiar Faces — Trial ${_currentTrialIndex + 1}/$_totalTrials",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick Settings / Caregiver Icon Button on top right
                      InkWell(
                        onTap: _openCaregiverMenu,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.colorSurfaceLow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colorPrimary.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppTheme.colorPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4-Segment Dignified Progress Bar
                  Row(
                    children: List.generate(_totalTrials, (index) {
                      final bool isActive = index <= _currentTrialIndex;
                      return Expanded(
                        child: Container(
                          height: 8,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 3,
                            right: index == _totalTrials - 1 ? 0 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.colorSecondary
                                : AppTheme.colorBorderGray.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Gentle Privacy Shield Pill Bar
                  const PrivacyConsentBanner(compact: true),
                ],
              ),
              const SizedBox(height: 10),

              // MAIN QUESTION & MEMORY CARD AREA
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuestionView(),
                    ],
                  ),
                ),
              ),

              // BOTTOM HINT ACTION BUTTON (Sticky to bottom)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _showHintDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorSurfaceLow,
                      foregroundColor: AppTheme.colorPrimary,
                      elevation: 1,
                      shadowColor: AppTheme.colorPrimary.withValues(alpha: 0.05),
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color: AppTheme.colorBorderGray.withValues(alpha: 0.5),
                      ),
                    ),
                    icon: const Icon(
                      Icons.lightbulb_rounded,
                      color: AppTheme.colorSecondary,
                      size: 22,
                    ),
                    label: const Text(
                      "Need a Hint? (Relationship Tag)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final bool showPhoto = _activeDifficulty == 'easy';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Visual Portrait Frame Area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 178),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colorPrimary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: showPhoto
              ? Center(
                  child: RealPersonAvatar(
                    photoUrl: _targetProfile.photoUrl,
                    localImagePath: _targetProfile.localImagePath,
                    personName: _targetProfile.name,
                    isCircular: true,
                    size: 112,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.colorSurfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_off_rounded,
                        color: AppTheme.colorPrimary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _activeDifficulty == 'hard'
                              ? "Hard Level: Match description to person (Photo & name hidden)"
                              : "Medium Level: Recall person from study card (Photo hidden)",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.colorTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),

        // Question Banner Card with Listen Question Button
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.colorSurfaceLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.colorBorderGray.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _questionPrompt,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colorPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppTheme.colorSecondaryFixed,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => TTSService().speak(_questionPrompt),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volume_up_rounded,
                          color: AppTheme.colorPrimary,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Listen Question",
                          style: TextStyle(
                            fontSize: 13,
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
        const SizedBox(height: 14),

        // 4 Answer Choice Cards (A, B, C, D)
        ...List.generate(_mcqOptions.length, (index) {
          final optionText = _mcqOptions[index];
          final prefixes = ['A', 'B', 'C', 'D'];
          final isSelected = _selectedOption == optionText;
          final isWrong = _wrongOption == optionText;
          final isCorrect = isSelected && optionText == _correctAnswer;

          return MCQChoiceCard(
            optionText: optionText,
            isSelected: isSelected,
            isWrong: isWrong,
            isCorrect: isCorrect,
            labelPrefix: prefixes[index],
            onTap: () => _onOptionSelected(optionText),
          );
        }),
      ],
    );
  }
}
