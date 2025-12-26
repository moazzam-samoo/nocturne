import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/downloads_controller.dart';
import '../controllers/music_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/player_controller.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DownloadsController controller = Get.put(DownloadsController());
    final MainController mainController = Get.find<MainController>();

    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            
            // Screen Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Text(
                  'Downloaded Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),

            Obx(() {
              if (controller.downloadedTracks.isEmpty) {
                 return const SliverFillRemaining(
                   child: Center(child: Text("No downloaded songs", style: TextStyle(color: Colors.white))),
                 );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = controller.downloadedTracks[index];
                    return ListTile(
                      leading: const Icon(Icons.music_note, color: Colors.white, size: 40),
                      title: Text(track.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(track.artistName, style: const TextStyle(color: Colors.grey)),
                       trailing: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Obx(() {
                           final isPlaying = Get.find<PlayerController>().currentTrack.value?.id == track.id &&
                               Get.find<PlayerController>().isPlaying.value;
                           return IconButton(
                             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.pink),
                             onPressed: () {
                               Get.find<PlayerController>().playTrack(track);
                               Get.find<MainController>().goToPlayer();
                             },
                           );
                         }),
                           IconButton(
                             icon: const Icon(Icons.delete, color: Colors.redAccent),
                             onPressed: () {
                               controller.deleteDownload(track);
                             },
                           ),
                         ],
                       ),
                    );
                 },
                 childCount: controller.downloadedTracks.length,
               ),
             );
           }),
           const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      }
    );
  }
}
