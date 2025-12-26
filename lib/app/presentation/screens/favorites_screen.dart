import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/main_controller.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FavoritesController controller = Get.put(FavoritesController());
    final MusicController musicController = Get.find<MusicController>();
     final MainController mainController = Get.find<MainController>();

    return Builder(
      builder: (context) {
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
                    'My Favorites',
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
                 if (controller.favorites.isEmpty) {
                   return const SliverFillRemaining(child: Center(child: Text('No favorites yet!', style: TextStyle(color: Colors.white))));
                 }
        
                 return SliverList(
                   delegate: SliverChildBuilderDelegate(
                     (context, index) {
                       final track = controller.favorites[index];
                       return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(track.albumImage, width: 50, height: 50, fit: BoxFit.cover, 
                            errorBuilder: (c,e,s) => const Icon(Icons.music_note, color: Colors.white)),
                          ),
                          title: Text(track.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(track.artistName, style: const TextStyle(color: Colors.grey)),
                          trailing: Obx(() {
                        final isPlaying = Get.find<PlayerController>().currentTrack.value?.id == track.id &&
                            Get.find<PlayerController>().isPlaying.value;
                        return IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.pink),
                          onPressed: () {
                             Get.find<PlayerController>().playTrack(track);
                             mainController.goToPlayer();
                          },
                        );
                      }),
                          onTap: () {
                            Get.find<PlayerController>().playTrack(track); // Dynamic find or add controller to class
                            mainController.goToPlayer();
                          },
                       );
                     },
                     childCount: controller.favorites.length,
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
