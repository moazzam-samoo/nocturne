import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/downloads_controller.dart';
import '../controllers/main_controller.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DownloadsController controller = Get.put(DownloadsController());
    final MainController mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.downloadedTracks.isEmpty) {
           return const Center(child: Text('No downloads yet.', style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: controller.downloadedTracks.length,
          itemBuilder: (context, index) {
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
        );
      }),
    );
  }
}
