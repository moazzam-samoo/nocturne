import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/player_controller.dart';
import '../screens/now_playing_screen.dart';
import 'glass_container.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController player = Get.find<PlayerController>();

    return Obx(() {
      final track = player.currentTrack.value;
      if (track == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.to(() => const NowPlayingScreen(), transition: Transition.downToUp),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10), // Margin for floating effect
          child: GlassContainer(
            width: double.infinity,
            height: 70, // Slightly compact
             borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Hero(
                  tag: 'mini_player_art_${track.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: track.albumImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white12),
                      errorWidget: (context, url, error) => const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        track.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    player.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    if (player.isPlaying.value) {
                      player.pause();
                    } else {
                      player.resume();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
