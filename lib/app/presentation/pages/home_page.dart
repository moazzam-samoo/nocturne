import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/mini_player.dart';
import '../widgets/animated_list_item.dart';
import 'search_page.dart';  // Will implement next

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MusicController controller = Get.find();
    final PlayerController playerController = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Classic Music', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => Get.to(() => const SearchPage()),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (controller.isTrendingLoading.value && controller.trendingTracks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                   if (controller.trendingError.value.isNotEmpty && controller.trendingTracks.isEmpty) {
                    return Center(child: Text(controller.trendingError.value));
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 100), // Space for MiniPlayer
                    children: [
                      // Recently Played (Mocking "Trending" as Recently Played for now as API doesn't have history)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: const Text('Trending Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: controller.trendingTracks.length,
                          itemBuilder: (context, index) {
                            final track = controller.trendingTracks[index];
                            return AnimatedListItem(
                              index: index,
                              child: GestureDetector(
                                onTap: () => playerController.playTrack(track),
                                child: Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Hero(
                                        tag: 'art_${track.id}',
                                        child: Container(
                                          height: 140,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(
                                              image: NetworkImage(track.albumImage),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        track.title, 
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // You Might Like (Regional)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: const Text('You Might Like', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      ...controller.regionalTracks.asMap().entries.map((entry) {
                         final index = entry.key;
                         final track = entry.value;
                         return AnimatedListItem(
                           index: index,
                           child: GestureDetector(
                             onTap: () => playerController.playTrack(track),
                             child: Container(
                               margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                               child: GlassContainer(
                                 height: 80,
                                 child: Row(
                                   children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(track.albumImage),
                                        radius: 25,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              track.title, 
                                              maxLines: 1, 
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                                            ),
                                            Text(
                                              track.artistName, 
                                               maxLines: 1, 
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white70, fontSize: 12)
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                         );
                      }).toList(),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: const MiniPlayer(),
    );
  }
}
