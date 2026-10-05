import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person_profile.dart';
import 'profile_repository.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _cloudMockStorageKey = 'mock_cloud_partitions_v1';
  static const String _lastSyncedCodeKey = 'last_synced_family_code_v1';

  /// Generate a random 6-digit Family Link Code (e.g. FAM-8921)
  String generateFamilyCode() {
    final rand = Random();
    final num = 1000 + rand.nextInt(9000);
    return 'FAM-$num';
  }

  /// Upload caregiver profiles to partition and return pairing code
  Future<String> uploadCaregiverDataset(List<PersonProfile> profiles) async {
    final code = generateFamilyCode();
    final prefs = await SharedPreferences.getInstance();
    
    // Read mock cloud store
    final rawCloud = prefs.getString(_cloudMockStorageKey) ?? '{}';
    final Map<String, dynamic> cloudStore = jsonDecode(rawCloud);
    
    // Store payload under partition key `code`
    final payload = profiles.map((p) => p.toJson()).toList();
    cloudStore[code] = jsonEncode(payload);
    
    await prefs.setString(_cloudMockStorageKey, jsonEncode(cloudStore));
    return code;
  }

  /// User device enters Family Link Code to download & cache dataset locally
  Future<List<PersonProfile>?> downloadAndCacheByCode(String familyCode) async {
    final code = familyCode.trim().toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    
    final rawCloud = prefs.getString(_cloudMockStorageKey) ?? '{}';
    final Map<String, dynamic> cloudStore = jsonDecode(rawCloud);
    
    if (!cloudStore.containsKey(code)) {
      return null; // Code not found
    }

    final rawPayload = cloudStore[code] as String;
    final List list = jsonDecode(rawPayload);
    final profiles = list.map((item) => PersonProfile.fromJson(item)).toList();

    // Cache locally to ProfileRepository
    for (var profile in profiles) {
      await ProfileRepository().addCaregiverProfile(profile.copyWith(isDemo: false));
    }

    await prefs.setString(_lastSyncedCodeKey, code);
    return profiles;
  }

  Future<String?> getLastSyncedCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncedCodeKey);
  }
}

