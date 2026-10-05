import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/person_profile.dart';
import '../models/caregiver_summary.dart';
import '../services/analytics_service.dart';
import '../services/profile_repository.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/real_person_avatar.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  List<PersonProfile> _profiles = [];
  CaregiverSummary? _summary;
  String? _generatedFamilyCode;
  bool _isUploadingSync = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ProfileRepository();
    await repo.init();
    final profileId = await repo.getActiveProfileId();
    final summary = await AnalyticsService().getCaregiverSummary(profileId);

    if (!mounted) return;

    setState(() {
      _profiles = repo.caregiverProfiles;
      _summary = summary;
    });
  }

  Future<void> _generateAndSyncFamilyCode() async {
    if (_profiles.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload at least 4 face profiles before generating a Family Link Code."),
        ),
      );
      return;
    }

    setState(() => _isUploadingSync = true);
    final code = await SyncService().uploadCaregiverDataset(_profiles);

    if (!mounted) return;

    setState(() {
      _generatedFamilyCode = code;
      _isUploadingSync = false;
    });
  }

  void _openAddEditProfileModal([PersonProfile? existingProfile]) {
    final nameController = TextEditingController(text: existingProfile?.name ?? '');
    final relationController = TextEditingController(text: existingProfile?.relationship ?? '');
    final cityController = TextEditingController(text: existingProfile?.city ?? '');
    
    final List<TextEditingController> noteControllers = (existingProfile?.contextNotes.isNotEmpty ?? false)
        ? existingProfile!.contextNotes.map((note) => TextEditingController(text: note)).toList()
        : [TextEditingController()];

    String? localImagePath = existingProfile?.localImagePath;
    String? photoUrl = existingProfile?.photoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.colorCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingProfile == null ? "Add Personal Face Profile" : "Edit Face Profile",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Photo Picker Header
                    Center(
                      child: Column(
                        children: [
                          RealPersonAvatar(
                            photoUrl: photoUrl,
                            localImagePath: localImagePath,
                            personName: nameController.text.isNotEmpty ? nameController.text : "P",
                            size: 110,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setModalState(() {
                                  localImagePath = picked.path;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.colorSecondary,
                              minimumSize: const Size(150, 44),
                            ),
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: const Text("Pick Photo from Gallery", style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextField(
                      controller: nameController,
                      onChanged: (val) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: "Full Name *",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Relationship Tag Field
                    TextField(
                      controller: relationController,
                      decoration: InputDecoration(
                        labelText: "Relationship Tag * (e.g. Daughter, Neighbor)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.family_restroom),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // City Field
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: "City / Location (Optional)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Context Note Fields Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Context Notes & Stories",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            setModalState(() {
                              noteControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          tooltip: "Add another context note field",
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...List.generate(noteControllers.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: noteControllers[idx],
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: "Context Note ${idx + 1}",
                                  hintText: "1–2 sentence narrative (e.g. Lives in Bangalore, loves ice cream)",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            if (noteControllers.length > 1) ...[
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.colorError),
                                onPressed: () {
                                  setModalState(() {
                                    noteControllers.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final relation = relationController.text.trim();
                        final city = cityController.text.trim();
                        final notes = noteControllers
                            .map((c) => c.text.trim())
                            .where((txt) => txt.isNotEmpty)
                            .toList();

                        if (name.isEmpty || relation.isEmpty) {
                          ScaffoldMessenger.of(modalCtx).showSnackBar(
                            const SnackBar(content: Text("Name and Relationship tag are required.")),
                          );
                          return;
                        }

                        final profile = PersonProfile(
                          id: existingProfile?.id ?? "caregiver_${DateTime.now().millisecondsSinceEpoch}",
                          name: name,
                          relationship: relation,
                          contextNotes: notes.isNotEmpty ? notes : ["$relation $name."],
                          localImagePath: localImagePath,
                          photoUrl: photoUrl,
                          isDemo: false,
                          city: city.isNotEmpty ? city : null,
                        );

                        if (existingProfile == null) {
                          await ProfileRepository().addCaregiverProfile(profile);
                        } else {
                          await ProfileRepository().updateCaregiverProfile(profile);
                        }

                        if (!modalCtx.mounted) return;

                        Navigator.pop(modalCtx);
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppTheme.colorPrimary,
                      ),
                      child: Text(
                        existingProfile == null ? "Save Face Profile" : "Update Profile",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        title: const Text("Caregiver Dashboard & Analytics"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Caregiver Analytics Summary Card
              if (_summary != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: AppTheme.colorPrimary, size: 28),
                            SizedBox(width: 10),
                            Text(
                              "Caregiver Trend Summary",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colorTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn("Total Sessions", "${_summary!.totalSessions}"),
                            _buildStatColumn("Avg Accuracy", "${(_summary!.averageAccuracy * 100).toInt()}%"),
                            _buildStatColumn("Avg Time", "${_summary!.averageCompletionTime}s"),
                            _buildStatColumn("Trend", _summary!.trend.toUpperCase()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Family Link Code Generator Banner
              Card(
                color: AppTheme.colorSecondaryFixed,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.phonelink_setup_rounded, color: AppTheme.colorPrimary, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Caregiver-to-User Device Sync",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colorTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Upload personal face profiles to cloud partition and share the 6-digit Family Link Code with the user device.",
                        style: TextStyle(fontSize: 14, color: AppTheme.colorTextSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      if (_generatedFamilyCode != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.colorPrimary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Family Link Code",
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _generatedFamilyCode!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isUploadingSync ? null : _generateAndSyncFamilyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colorPrimary,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        icon: _isUploadingSync
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload_rounded),
                        label: Text(
                          _generatedFamilyCode == null ? "Generate Family Link Code" : "Re-Sync & Update Code",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Caregiver Uploaded Face Profiles Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Personal Face Profiles (${_profiles.length})",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openAddEditProfileModal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorPrimary,
                      minimumSize: const Size(120, 48),
                    ),
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text("Add Profile"),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_profiles.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.no_photography_outlined, size: 48, color: AppTheme.colorTextSecondary),
                        const SizedBox(height: 12),
                        const Text(
                          "No personal face profiles uploaded yet.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Caregivers must upload at least 4 clear face photos to enable personalized gameplay.",
                          style: TextStyle(fontSize: 14, color: AppTheme.colorTextSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _profiles.length,
                  itemBuilder: (ctx, index) {
                    final profile = _profiles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: RealPersonAvatar(
                          photoUrl: profile.photoUrl,
                          localImagePath: profile.localImagePath,
                          personName: profile.name,
                          size: 56,
                        ),
                        title: Text(
                          profile.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tag: ${profile.relationship}", style: const TextStyle(color: AppTheme.colorPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text("${profile.contextNotes.length} context note(s)"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.colorPrimary),
                              onPressed: () => _openAddEditProfileModal(profile),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.colorError),
                              onPressed: () async {
                                await ProfileRepository().deleteCaregiverProfile(profile.id);
                                if (!mounted) return;
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.colorTextSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.colorPrimary),
        ),
      ],
    );
  }
}
