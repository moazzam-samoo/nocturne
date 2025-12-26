import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trending_controller.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/main_controller.dart';

class TrendingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TrendingController controller = Get.put(TrendingController());
    final MusicController musicController = Get.find<MusicController>();
    final MainController mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from MainScreen
      appBar: AppBar(
        title: const Text('Trending Hits (2020-2025)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }
        
        return RefreshIndicator(
          onRefresh: controller.fetchTrending,
          child: ListView.builder(
            itemCount: controller.trendingTracks.length,
            itemBuilder: (context, index) {
              final track = controller.trendingTracks[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(track.albumImage, width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(track.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(track.artistName, style: const TextStyle(color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => musicController.downloadTrack(track),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.pink),
                      onPressed: () {
                         Get.find<PlayerController>().playTrack(track);
                         mainController.goToPlayer();
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Get.find<PlayerController>().playTrack(track);
                  mainController.goToPlayer();
                },
              );
            },
          ),
        );
      }),
    );
  }
}
