import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/downloads_controller.dart';
import '../controllers/main_controller.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DownloadsController controller = Get.put(DownloadsController());
    final MainController mainController = Get.find<MainController>();

    return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          
          // Screen Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Downloads',
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
               return const SliverFillRemaining(child: Center(child: Text('No downloads yet.', style: TextStyle(color: Colors.white))));
            }
    
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                   final track = controller.downloadedTracks[index];
                   return ListTile(
                     leading: const Icon(Icons.music_note, color: Colors.white, size: 40), // Or generic image
                     title: Text(track.name, style: const TextStyle(color: Colors.white)),
                     subtitle: Text(track.artistName, style: const TextStyle(color: Colors.grey)),
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.play_circle_fill, color: Colors.green),
                           onPressed: () {
                              controller.playDownloadedTrack(track);
                              mainController.goToPlayer();
                           },
                         ),
                         IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red),
                           onPressed: () => controller.deleteDownload(track),
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
}
