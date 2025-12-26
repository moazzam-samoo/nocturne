import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/glass_container.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicController musicController = Get.find();
    final PlayerController playerController = Get.find();
    final TextEditingController searchInputController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E0249),
            Color(0xFFA91079),
            Color(0xFF000000),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
               // Reset search when going back if desired, or keep state
               Get.back();
            },
          ),
          title: const Text('Search', style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: BorderRadius.circular(15),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: TextField(
                      controller: searchInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Search songs, artists...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white70),
                      ),
                      onSubmitted: (value) {
                        musicController.search(value);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (musicController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (musicController.tracks.isEmpty) {
                    return Center(
                      child: Text(
                        musicController.errorMessage.value.isNotEmpty 
                            ? musicController.errorMessage.value 
                            : "Search for your favorite music",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: musicController.tracks.length,
                    itemBuilder: (context, index) {
                      final track = musicController.tracks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: GlassContainer(
                          width: double.infinity,
                          height: 80,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
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
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: Color(0xFFA91079), size: 40),
                                onPressed: () {
                                  playerController.playTrack(track);
                                  Get.snackbar('Playing', 'Now playing ${track.name}', 
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.white24,
                                    colorText: Colors.white,
                                  );
                                },
                              ),
                            ],
                          ),
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
