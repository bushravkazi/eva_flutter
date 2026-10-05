import 'dart:convert';

/// API Contract v1.0 — Caregiver Trend Summary
class CaregiverSummary {
  final String profileId;
  final String gameType;
  final double averageAccuracy;
  final int averageCompletionTime;
  final int totalSessions;
  final String trend; // "improving", "stable", "needs_support"
  final String currentDifficulty;

  CaregiverSummary({
    required this.profileId,
    this.gameType = "familiar_faces",
    required this.averageAccuracy,
    required this.averageCompletionTime,
    required this.totalSessions,
    required this.trend,
    required this.currentDifficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      "profileId": profileId,
      "gameType": gameType,
      "averageAccuracy": averageAccuracy,
      "averageCompletionTime": averageCompletionTime,
      "totalSessions": totalSessions,
      "trend": trend,
      "currentDifficulty": currentDifficulty,
    };
  }

  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory CaregiverSummary.fromJson(Map<String, dynamic> json) {
    return CaregiverSummary(
      profileId: json['profileId'] as String,
      gameType: json['gameType'] as String? ?? "familiar_faces",
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      averageCompletionTime: json['averageCompletionTime'] as int,
      totalSessions: json['totalSessions'] as int,
      trend: json['trend'] as String,
      currentDifficulty: json['currentDifficulty'] as String,
    );
  }
}

