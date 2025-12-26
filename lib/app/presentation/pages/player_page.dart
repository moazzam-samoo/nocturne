import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'lyrics_page.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Obx(() {
          final track = controller.currentTrack.value;
          if (track == null) return const Center(child: Text('No Track Playing'));

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Circular Art with Hero
              Hero(
                tag: 'album_art_${track.id}',
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(track.albumImage),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title & Artist
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      track.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      track.artistName,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Progress Bar (Waveform effect visual)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ProgressBar(
                  progress: controller.progress.value,
                  buffered: controller.buffered.value,
                  total: controller.totalDuration.value,
                  onSeek: controller.seek,
                  baseBarColor: Colors.white.withOpacity(0.3),
                  progressBarColor: const Color(0xFFA91079),
                  bufferedBarColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  barHeight: 4,
                  thumbRadius: 8,
                  timeLabelTextStyle: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                    onPressed: () {}, // Implement Prev/Next if list available in PlayerController
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: controller.togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Or glass
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                        ]
                      ),
                      child: Icon(
                        controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xFF2E0249),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const Spacer(),
              // Lyrics Button Area
              GestureDetector(
                onTap: () => Get.to(() => LyricsPage()),
                child: GlassContainer(
                  width: 200,
                  height: 50,
                  borderRadius: 30,
                  child: const Center(child: Text("Lyrics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        }),
      ),
    );
  }
}
