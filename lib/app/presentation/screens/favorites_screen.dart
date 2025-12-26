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

    return Scaffold(
       backgroundColor: Colors.transparent,
       appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
       body: Obx(() {
         if (controller.favorites.isEmpty) {
           return const Center(child: Text('No favorites yet!', style: TextStyle(color: Colors.white)));
         }

         return ListView.builder(
           itemCount: controller.favorites.length,
           itemBuilder: (context, index) {
             final track = controller.favorites[index];
             return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(track.albumImage, width: 50, height: 50, fit: BoxFit.cover, 
                  errorBuilder: (c,e,s) => const Icon(Icons.music_note, color: Colors.white)),
                ),
                title: Text(track.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(track.artistName, style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.pink),
                  onPressed: () => controller.toggleFavorite(track),
                ),
                onTap: () {
                  Get.find<PlayerController>().playTrack(track); // Dynamic find or add controller to class
                  mainController.goToPlayer();
                },
             );
           },
         );
       }),
    );
  }
}
