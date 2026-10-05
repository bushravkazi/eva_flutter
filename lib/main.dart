import 'package:flutter/material.dart';

// Face Rec Game Imports
import 'games/face_rec/services/profile_repository.dart';
import 'games/face_rec/services/tts_service.dart';
import 'games/face_rec/screens/game_screen.dart';

// Dance Along Game Imports
import 'games/dance_along/dance_along_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first profile storage & TTS engine
  await ProfileRepository().init();
  await TTSService().init();

  runApp(const MasterHubApp());
}

class MasterHubApp extends StatelessWidget {
  const MasterHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognitive Game Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const GameHubScreen(),
    );
  }
}

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Launcher Hub'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.face, size: 36, color: Colors.blue),
              title: const Text(
                'Familiar Faces',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Cognitive Memory Support'),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.directions_run_rounded, size: 36, color: Color(0xFF35618F)),
              title: const Text(
                'Regional Dance Follower',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Physical & Movement Routine'),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DanceAlongMainScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}