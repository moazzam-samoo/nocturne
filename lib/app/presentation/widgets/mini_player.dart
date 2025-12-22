import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/player_controller.dart';
import '../pages/player_page.dart';
import 'glass_container.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find();

    return Obx(() {
      final track = controller.currentTrack.value;
      if (track == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.to(() => const PlayerPage(), transition: Transition.downToUp),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GlassContainer(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Art
                Hero(
                  tag: 'album_art_${track.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25), // Circular
                      image: DecorationImage(
                        image: NetworkImage(track.albumImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        track.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Controls
                IconButton(
                  icon: Icon(
                    controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: controller.togglePlayPause,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
