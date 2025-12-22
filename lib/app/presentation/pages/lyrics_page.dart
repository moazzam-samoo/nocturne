import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';

class LyricsPage extends StatelessWidget {
  const LyricsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Lyrics", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Obx(() {
          final track = controller.currentTrack.value;
           if (track == null) return const Center(child: Text("No track selected", style: TextStyle(color: Colors.white)));
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image faded
              Opacity(
                opacity: 0.2,
                child: Image.network(
                  track.artistImage.isNotEmpty ? track.artistImage : track.albumImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const SizedBox(),
                ),
              ),
              
              // Lyrics Content (Mocked as API doesn't guarantee lyrics)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                         Text(
                          "Lyrics for ${track.title}", 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Unfortunately, Jamendo API does not provide lyrics for all tracks.\n\n"
                          "This is a placeholder for the lyrics screen.\n"
                          "Imagine beautiful karaoke-style text scrolling here...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
