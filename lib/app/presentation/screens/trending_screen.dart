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

    return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              
          // Screen Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Trending Hits (2020-2025)',
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
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Colors.pink)));
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = controller.trendingTracks[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(track.albumImage,
                          width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(track.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(track.artistName,
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download,
                              color: Colors.white),
                          onPressed: () =>
                              musicController.downloadTrack(track),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow,
                              color: Colors.pink),
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
                childCount: controller.trendingTracks.length,
              ),
            );
          }),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
    );
  }
}
