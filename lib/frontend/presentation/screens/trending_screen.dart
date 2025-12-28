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
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'All Songs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),

              // Alphabet Selector
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.alphabets.length,
                    itemBuilder: (context, index) {
                      final alphabet = controller.alphabets[index];
                      return Obx(() {
                        final isSelected = controller.selectedAlphabet.value == alphabet;
                        return GestureDetector(
                          onTap: () => controller.fetchSongsByAlphabet(alphabet),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFA91079) : Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: isSelected ? null : Border.all(color: Colors.white24),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFFA91079).withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1)
                                    ]
                                  : [],
                            ),
                            child: Text(
                              alphabet,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      });
                    },
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

                if (controller.displayedTracks.isEmpty) {
                   return const SliverFillRemaining(
                      child: Center(
                          child: Text("No songs found", style: TextStyle(color: Colors.white54))));
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = controller.displayedTracks[index];
                      return Dismissible(
                         // Using Dismissible purely for animation on entry or interaction could be nice, 
                         // but here standard list tile with animations is better. 
                         // Let's stick to standard ListTile but styled nicely.
                         key: ValueKey(track.id),
                         child: Container(
                           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.05),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.white10),
                           ),
                           child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(track.albumImage,
                                  width: 50, height: 50, fit: BoxFit.cover,
                                  errorBuilder: (c,e,s) => const Icon(Icons.music_note, color: Colors.white)),
                            ),
                            title: Text(track.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            subtitle: Text(track.artistName,
                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                           ),
                         ),
                      );
                    },
                    childCount: controller.displayedTracks.length,
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
