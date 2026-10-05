import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/performance_data.dart';
import '../models/caregiver_summary.dart';
import 'adaptive_engine.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _sessionLogsKey = 'session_performance_logs_v1';

  /// Save session log matching POST /performance API contract
  Future<void> recordSession(PerformanceData data) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getSessionLogs();
    logs.add(data);

    final rawJsonList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_sessionLogsKey, jsonEncode(rawJsonList));
  }

  Future<List<PerformanceData>> getSessionLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_sessionLogsKey);
    if (rawData == null || rawData.isEmpty) return [];

    try {
      final List list = jsonDecode(rawData);
      return list.map((item) => PerformanceData.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate Caregiver Trend Summary (Section 9 of API Contract)
  Future<CaregiverSummary> getCaregiverSummary(String profileId, {String gameType = "familiar_faces"}) async {
    final allLogs = await getSessionLogs();
    final profileLogs = allLogs.where((l) => l.profileId == profileId && l.gameType == gameType).toList();

    if (profileLogs.isEmpty) {
      return CaregiverSummary(
        profileId: profileId,
        gameType: gameType,
        averageAccuracy: 0.0,
        averageCompletionTime: 0,
        totalSessions: 0,
        trend: "stable",
        currentDifficulty: "easy",
      );
    }

    double totalAccuracy = 0.0;
    int totalTime = 0;

    for (var log in profileLogs) {
      totalAccuracy += log.accuracy;
      totalTime += log.completionTime;
    }

    final avgAcc = totalAccuracy / profileLogs.length;
    final avgTime = totalTime ~/ profileLogs.length;

    // Evaluate trend over recent sessions
    String trend = "stable";
    if (profileLogs.length >= 3) {
      final recent = profileLogs.sublist(profileLogs.length - 3);
      final recentAvg = recent.fold<double>(0.0, (sum, item) => sum + item.accuracy) / 3;
      if (recentAvg >= 0.80) {
        trend = "improving";
      } else if (recentAvg < 0.60) {
        trend = "needs_support";
      }
    }

    final currentDiff = await AdaptiveEngineService().getNextDifficulty(profileId, gameType: gameType);

    return CaregiverSummary(
      profileId: profileId,
      gameType: gameType,
      averageAccuracy: double.parse(avgAcc.toStringAsFixed(2)),
      averageCompletionTime: avgTime,
      totalSessions: profileLogs.length,
      trend: trend,
      currentDifficulty: currentDiff,
    );
  }

  /// Simulate POST /performance network endpoint transmission
  Future<Map<String, dynamic>> sendPerformancePayload(PerformanceData data) async {
    await recordSession(data);
    final adaptiveResp = await AdaptiveEngineService().processPerformance(data);

    return {
      "status": 200,
      "message": "Performance logged successfully",
      "requestPayload": data.toJson(),
      "adaptiveResponse": adaptiveResp.toJson(),
    };
  }
}

