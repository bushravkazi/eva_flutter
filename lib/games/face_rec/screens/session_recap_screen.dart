import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../models/adaptive_response.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class SessionRecapScreen extends StatefulWidget {
  final PerformanceData performance;
  final int totalTrials;
  final int firstTryCorrectCount;

  const SessionRecapScreen({
    super.key,
    required this.performance,
    required this.totalTrials,
    required this.firstTryCorrectCount,
  });

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  AdaptiveResponse? _adaptiveResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processSession();
  }

  Future<void> _processSession() async {
    final res = await AnalyticsService().sendPerformancePayload(widget.performance);
    final adaptiveJson = res['adaptiveResponse'] as Map<String, dynamic>;

    if (!mounted) return;

    setState(() {
      _adaptiveResponse = AdaptiveResponse.fromJson(adaptiveJson);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (widget.performance.accuracy * 100).toInt();
    final unlockedNext = accuracyPct >= 80;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Summary"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result Header Badge
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              unlockedNext ? Icons.stars_rounded : Icons.check_circle_outline_rounded,
                              color: unlockedNext ? AppTheme.colorAccentWarm : AppTheme.colorSecondaryAction,
                              size: 64,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              unlockedNext ? "Great Progress!" : "Activity Completed!",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colorTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              unlockedNext
                                  ? "You achieved $accuracyPct% accuracy and unlocked the next difficulty tier!"
                                  : "Completed at $accuracyPct% accuracy. Keep up the regular memory support routines!",
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.colorTextSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metrics Grid
                    Row(
                      children: [
                        _buildMetricTile(
                          title: "Accuracy",
                          value: "$accuracyPct%",
                          icon: Icons.pie_chart_rounded,
                          color: unlockedNext ? AppTheme.colorSuccess : AppTheme.colorAccentWarm,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          title: "Duration",
                          value: "${widget.performance.completionTime}s",
                          icon: Icons.timer_outlined,
                          color: AppTheme.colorSecondaryAction,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMetricTile(
                          title: "First Try",
                          value: "${widget.firstTryCorrectCount}/${widget.totalTrials}",
                          icon: Icons.task_alt_rounded,
                          color: AppTheme.colorSecondaryAction,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          title: "Errors / Retries",
                          value: "${widget.performance.errorCount} / ${widget.performance.retries}",
                          icon: Icons.refresh_rounded,
                          color: widget.performance.errorCount > 0 ? AppTheme.colorError : AppTheme.colorSuccess,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Adaptive Difficulty Decision Card (API Contract v1.0)
                    if (_adaptiveResponse != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.tune_rounded, color: AppTheme.colorAccentWarm, size: 28),
                                  SizedBox(width: 10),
                                  Text(
                                    "Adaptive Engine Decision",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.colorTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDiffChip("Previous", _adaptiveResponse!.previousDifficulty),
                                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.colorAccentWarm),
                                  _buildDiffChip("Recommended Next", _adaptiveResponse!.newDifficulty),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.colorBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppTheme.colorTextSecondary, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Action: ${_adaptiveResponse!.action.toUpperCase()} — Reason: ${_adaptiveResponse!.reason}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.colorTextSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Dementia Platform API Contract JSON Inspector Toggle
                    ExpansionTile(
                      title: const Text(
                        "Dementia Platform API Contract Payload (v1.0)",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.code_rounded, color: AppTheme.colorSecondaryAction),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "// POST /performance Request Body:\n${widget.performance.toFormattedJson()}\n\n// Adaptive Engine Response:\n${_adaptiveResponse?.toFormattedJson() ?? ''}",
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: Color(0xFF4EC9B0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Navigation Action Buttons
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              useCaregiverData: false,
                              selectedDifficulty: _adaptiveResponse?.newDifficulty ?? 'easy',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: AppTheme.colorAccentWarm,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: Text(
                        "Play Next Session (${(_adaptiveResponse?.newDifficulty ?? 'easy').toUpperCase()})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: AppTheme.colorSecondaryAction, width: 2),
                      ),
                      icon: const Icon(Icons.home_rounded, color: AppTheme.colorSecondaryAction),
                      label: const Text(
                        "Return to Home Screen",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorSecondaryAction,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.colorCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colorSurface),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.colorTextSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffChip(String label, String diff) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.colorTextSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.colorAccentWarm.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.colorAccentWarm),
          ),
          child: Text(
            diff.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.colorAccentWarm,
            ),
          ),
        ),
      ],
    );
  }
}
