import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_list_item.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MusicController controller = Get.find();
    final PlayerController playerController = Get.find();
    final TextEditingController searchInput = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Search', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: TextField(
                      controller: searchInput,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search songs, artists...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white),
                      ),
                      onSubmitted: (value) => controller.search(value),
                    ),
                  ),
                ),
              ),

              // Results
              Expanded(
                child: Obx(() {
                  if (controller.isSearchLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.searchError.value.isNotEmpty) {
                     return Center(child: Text('Error: ${controller.searchError.value}'));
                  }

                  if (controller.searchResults.isEmpty) {
                    return const Center(child: Text("Search for your favorite music", style: TextStyle(color: Colors.white54)));
                  }

                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final track = controller.searchResults[index];
                      return AnimatedListItem(
                        index: index,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(track.albumImage, width: 50, height: 50, fit: BoxFit.cover, 
                              errorBuilder: (_,__,___) => Container(color: Colors.grey, width: 50, height: 50),
                            ),
                          ),
                          title: Text(track.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(track.artistName, style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            onPressed: () => playerController.playTrack(track),
                          ),
                          onTap: () => playerController.playTrack(track),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
