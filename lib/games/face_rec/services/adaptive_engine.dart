import 'package:shared_preferences/shared_preferences.dart';
import '../models/performance_data.dart';
import '../models/adaptive_response.dart';

class AdaptiveEngineService {
  static final AdaptiveEngineService _instance = AdaptiveEngineService._internal();
  factory AdaptiveEngineService() => _instance;
  AdaptiveEngineService._internal();

  static const String _difficultyStateKeyPrefix = 'adaptive_difficulty_';

  /// Evaluate session performance and determine next difficulty level + explainability reason
  Future<AdaptiveResponse> processPerformance(PerformanceData data) async {
    final currentLevel = data.difficultyLevel.toLowerCase();
    String newLevel = currentLevel;
    String action = "maintain";
    String reason = "performance_within_target_range";

    if (data.accuracy >= 0.80) {
      // High accuracy -> Increase difficulty
      if (currentLevel == "easy") {
        newLevel = "medium";
        action = "increase";
        reason = "repeated_high_accuracy";
      } else if (currentLevel == "medium") {
        newLevel = "hard";
        action = "increase";
        reason = "repeated_high_accuracy";
      } else {
        newLevel = "hard";
        action = "maintain";
        reason = "performance_within_target_range";
      }
    } else if (data.accuracy < 0.60 || data.errorCount >= 4) {
      // Low accuracy or high error count -> Decrease difficulty
      if (currentLevel == "hard") {
        newLevel = "medium";
        action = "decrease";
        reason = data.errorCount >= 4 ? "high_error_rate" : "repeated_low_accuracy";
      } else if (currentLevel == "medium") {
        newLevel = "easy";
        action = "decrease";
        reason = data.errorCount >= 4 ? "high_error_rate" : "repeated_low_accuracy";
      } else {
        newLevel = "easy";
        action = "maintain";
        reason = "performance_within_target_range";
      }
    } else if (data.hintsUsed >= 3) {
      action = "maintain";
      reason = "frequent_hints";
    }

    final response = AdaptiveResponse(
      previousDifficulty: currentLevel,
      newDifficulty: newLevel,
      action: action,
      reason: reason,
    );

    // Save recommended next difficulty for profile
    await _saveNextDifficulty(data.profileId, data.gameType, newLevel);

    return response;
  }

  Future<void> _saveNextDifficulty(String profileId, String gameType, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "$_difficultyStateKeyPrefix${profileId}_$gameType";
    await prefs.setString(key, difficulty);
  }

  Future<String> getNextDifficulty(String profileId, {String gameType = "familiar_faces"}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "$_difficultyStateKeyPrefix${profileId}_$gameType";
    return prefs.getString(key) ?? "easy";
  }
}

