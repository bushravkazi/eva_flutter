import 'dart:convert';

/// Strict API Contract Data Model — Dementia Platform API v1.0
class PerformanceData {
  final String profileId;
  final String gameType; // Always "familiar_faces"
  final String difficultyLevel; // "easy", "medium", "hard"
  final double accuracy; // 0.0 to 1.0
  final int errorCount;
  final int completionTime; // seconds
  final int hintsUsed;
  final int retries;
  final bool completed;

  PerformanceData({
    required this.profileId,
    this.gameType = "familiar_faces",
    required this.difficultyLevel,
    required this.accuracy,
    required this.errorCount,
    required this.completionTime,
    required this.hintsUsed,
    required this.retries,
    required this.completed,
  }) {
    assert(accuracy >= 0.0 && accuracy <= 1.0, 'Accuracy must be between 0.0 and 1.0');
  }

  Map<String, dynamic> toJson() {
    return {
      "profileId": profileId,
      "gameType": gameType,
      "difficultyLevel": difficultyLevel,
      "accuracy": accuracy,
      "errorCount": errorCount,
      "completionTime": completionTime,
      "hintsUsed": hintsUsed,
      "retries": retries,
      "completed": completed,
    };
  }

  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      profileId: json['profileId'] as String,
      gameType: json['gameType'] as String? ?? "familiar_faces",
      difficultyLevel: json['difficultyLevel'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      errorCount: json['errorCount'] as int,
      completionTime: json['completionTime'] as int,
      hintsUsed: json['hintsUsed'] as int,
      retries: json['retries'] as int,
      completed: json['completed'] as bool,
    );
  }
}

