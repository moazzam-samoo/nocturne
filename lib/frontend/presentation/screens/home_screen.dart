import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../backend/domain/entities/track.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/main_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/fancy_action_button.dart';
import 'now_playing_screen.dart'; 
// import 'search_screen.dart'; // Removed as Search is now in Main App Bar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicController musicController = Get.find();
    final PlayerController playerController = Get.find();

    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: () async {
            await musicController.fetchTracksByCategory();
          },
          color: const Color(0xFFA91079),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Recently Played'),
                      const SizedBox(height: 10),
                      _buildRecentlyPlayedList(musicController, playerController),
                      const SizedBox(height: 20),
                      _buildCategoryTabs(musicController),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              // Use SliverFillRemaining or just another Adapter for the rest
               SliverToBoxAdapter(
                 child: SizedBox(
                  height: 400, // Fixed height or use SliverList if dynamic
                  child: _buildYouMightLikeList(musicController, playerController)
                 ),
               ),
               const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for MiniPlayer
            ],
          ),
        );
      }
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit', // Or system default if not loaded
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayedList(MusicController controller, PlayerController player) {
    return SizedBox(
      height: 160,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.tracks.isEmpty) {
          return const Center(child: Text('No tracks found', style: TextStyle(color: Colors.white)));
        }
        
        // Just mocking "Recently Played" with the first few tracks for now
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: controller.tracks.length > 5 ? 5 : controller.tracks.length,
          itemBuilder: (context, index) {
            final track = controller.tracks[index];
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                onTap: () {
                   player.playTrack(track);
                   Get.find<MainController>().goToPlayer();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'recent_${track.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: track.albumImage,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white12),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildYouMightLikeList(MusicController controller, PlayerController player) {
     return Obx(() {
        if (controller.tracks.length < 5) return const SizedBox.shrink();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.tracks.length - 5,
          itemBuilder: (context, index) {
            final track = controller.tracks[index + 5]; // Skip first 5
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: GestureDetector(
                onTap: () {
                   player.playTrack(track);
                   Get.find<MainController>().goToPlayer();
                },
                child: GlassContainer(
                  width: double.infinity,
                  height: 80,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30), // Circular image
                        child: CachedNetworkImage(
                          imageUrl: track.albumImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                           placeholder: (context, url) => Container(color: Colors.white12),
                           errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              track.artistName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Keep the play button visual for affordance, but row is actionable
                      FancyActionButton(
                        icon: Icons.play_arrow,
                        isPrimary: true,
                        size: 20,
                        onPressed: () {
                           player.playTrack(track);
                           Get.find<MainController>().goToPlayer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
     });
  }


  Widget _buildCategoryTabs(MusicController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          _buildTabButton(controller, 0, 'Indian Songs'),
          const SizedBox(width: 15),
          _buildTabButton(controller, 1, 'Hollywood Songs'),
        ],
      ),
    );
  }

  Widget _buildTabButton(MusicController controller, int index, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchCategory(index),
        child: Obx(() {
          final isSelected = controller.selectedCategoryIndex.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFA91079) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(color: Colors.white12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFA91079).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }),
      ),
    );
  }
}
