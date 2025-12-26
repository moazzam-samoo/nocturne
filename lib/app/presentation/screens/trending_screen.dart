import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trending_controller.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/main_controller.dart';
import '../widgets/fancy_action_button.dart';

class TrendingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TrendingController controller = Get.put(TrendingController());
    final MusicController musicController = Get.find<MusicController>();
    final MainController mainController = Get.find<MainController>();

    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchTrending();
          },
          color: Colors.pink,
          child: CustomScrollView(
            slivers: [
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
                            FancyActionButton(
                              icon: Icons.download,
                              isPrimary: false,
                              size: 20,
                              onPressed: () => musicController.downloadTrack(track),
                            ),
                            const SizedBox(width: 10),
                            Obx(() {
                              final isPlaying = Get.find<PlayerController>().currentTrack.value?.id == track.id &&
                                  Get.find<PlayerController>().isPlaying.value;
                              return FancyActionButton(
                                icon: isPlaying ? Icons.pause : Icons.play_arrow,
                                isPrimary: true,
                                size: 20,
                                onPressed: () {
                                  Get.find<PlayerController>().playTrack(track);
                                  mainController.goToPlayer();
                                },
                              );
                            }),
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
          ),
        );
      }
    );
  }
}
