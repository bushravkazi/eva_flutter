import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person_profile.dart';

class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  static const String _caregiverStorageKey = 'caregiver_person_profiles_v1';
  static const String _activeProfileIdKey = 'active_user_profile_id_v1';

  // Privacy-safe built-in demo dataset featuring Indian faces for target relationships:
  // Daughter, Son, Granddaughter, Neighbour, Friend, Wife
  static final List<PersonProfile> _demoProfiles = [
    PersonProfile(
      id: 'demo_001',
      name: 'Ananya',
      relationship: 'Daughter',
      contextNotes: [
        'Ananya lives in Mumbai and loves making warm masala chai every morning.',
        'Works as a software engineer and visits home every month with fresh sweets.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '32',
      city: 'Mumbai',
    ),
    PersonProfile(
      id: 'demo_002',
      name: 'Aarav',
      relationship: 'Son',
      contextNotes: [
        'Aarav lives in Delhi and works as a doctor at the civil hospital.',
        'Loves playing badminton on weekends and brings fresh fruit juices during visits.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '38',
      city: 'Delhi',
    ),
    PersonProfile(
      id: 'demo_003',
      name: 'Sana',
      relationship: 'Granddaughter',
      contextNotes: [
        'Sana lives in Delhi and loves eating mango ice cream after school.',
        'Plays youth badminton on Saturdays and paints watercolor flowers.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '12',
      city: 'Delhi',
    ),
    PersonProfile(
      id: 'demo_004',
      name: 'Mr. Patel',
      relationship: 'Neighbour',
      contextNotes: [
        'Mr. Patel brings over fresh morning tea every Tuesday.',
        'Worked as a professor for 30 years and loves talking about astronomy.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '72',
      city: 'Chennai',
    ),
    PersonProfile(
      id: 'demo_005',
      name: 'Ramesh',
      relationship: 'Friend',
      contextNotes: [
        'Ramesh meets every evening for peaceful park walks and laughter.',
        'Enjoys playing carrom on Sunday afternoons and listening to classic melodies.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '68',
      city: 'Chennai',
    ),
    PersonProfile(
      id: 'demo_006',
      name: 'Lakshmi',
      relationship: 'Wife',
      contextNotes: [
        'Lakshmi loves watering green plants in the courtyard and preparing warm kheer.',
        'Enjoys peaceful evening prayers and singing classical devotional melodies.'
      ],
      photoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80',
      isDemo: true,
      age: '74',
      city: 'Chennai',
    ),
  ];

  List<PersonProfile> _caregiverProfiles = [];

  List<PersonProfile> get demoProfiles => List.unmodifiable(_demoProfiles);
  List<PersonProfile> get caregiverProfiles => List.unmodifiable(_caregiverProfiles);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_caregiverStorageKey);
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final List list = jsonDecode(rawData);
        _caregiverProfiles = list.map((item) => PersonProfile.fromJson(item)).toList();
      } catch (e) {
        _caregiverProfiles = [];
      }
    }
  }

  Future<void> saveCaregiverProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_caregiverProfiles.map((p) => p.toJson()).toList());
    await prefs.setString(_caregiverStorageKey, data);
  }

  Future<void> addCaregiverProfile(PersonProfile profile) async {
    _caregiverProfiles.add(profile);
    await saveCaregiverProfiles();
  }

  Future<void> updateCaregiverProfile(PersonProfile profile) async {
    final idx = _caregiverProfiles.indexWhere((p) => p.id == profile.id);
    if (idx != -1) {
      _caregiverProfiles[idx] = profile;
      await saveCaregiverProfiles();
    }
  }

  Future<void> deleteCaregiverProfile(String id) async {
    _caregiverProfiles.removeWhere((p) => p.id == id);
    await saveCaregiverProfiles();
  }

  /// Automatically fetch active dataset:
  /// If caregiver uploaded >= 4 pictures, auto use caregiver dataset;
  /// else auto use demo dataset with real people photos.
  List<PersonProfile> getAutoDataset() {
    if (_caregiverProfiles.length >= 4) {
      return List.unmodifiable(_caregiverProfiles);
    }
    return List.unmodifiable(_demoProfiles);
  }

  Future<String> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileIdKey) ?? "elderly_001";
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, id);
  }
}
