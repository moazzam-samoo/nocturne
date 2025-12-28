import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/downloads_controller.dart';
import '../controllers/music_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/fancy_action_button.dart';

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
                    return Dismissible(
                      key: Key('download_${track.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await Get.dialog<bool>(
                          AlertDialog(
                            backgroundColor: const Color(0xFF24243E),
                            title: const Text('Delete Download', style: TextStyle(color: Colors.white)),
                            content: Text('Are you sure you want to delete "${track.name}"?', 
                                style: const TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        controller.deleteDownload(track);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Play the track when the row is clicked
                            Get.find<PlayerController>().playTrack(track);
                            Get.find<MainController>().goToPlayer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white24, width: 1), // The requested border
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.music_note, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        track.artistName,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                  Obx(() {
                                    final isPlaying = Get.find<PlayerController>().currentTrack.value?.id == track.id &&
                                        Get.find<PlayerController>().isPlaying.value;
                                    return FancyActionButton(
                                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                                      isPrimary: true,
                                      size: 20,
                                      onPressed: () {
                                        Get.find<PlayerController>().playTrack(track);
                                        Get.find<MainController>().goToPlayer();
                                      },
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
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
