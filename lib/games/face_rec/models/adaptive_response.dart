import 'dart:convert';

/// API Contract v1.0 — Adaptive Difficulty Response
class AdaptiveResponse {
  final String previousDifficulty;
  final String newDifficulty;
  final String action; // "increase", "decrease", "maintain"
  final String reason; // reason code string

  AdaptiveResponse({
    required this.previousDifficulty,
    required this.newDifficulty,
    required this.action,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      "previousDifficulty": previousDifficulty,
      "newDifficulty": newDifficulty,
      "action": action,
      "reason": reason,
    };
  }

  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory AdaptiveResponse.fromJson(Map<String, dynamic> json) {
    return AdaptiveResponse(
      previousDifficulty: json['previousDifficulty'] as String,
      newDifficulty: json['newDifficulty'] as String,
      action: json['action'] as String,
      reason: json['reason'] as String,
    );
  }
}

