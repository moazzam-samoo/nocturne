import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/main_controller.dart';
import '../widgets/glass_container.dart';

class SearchResultsOverlay extends StatelessWidget {
  const SearchResultsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicController musicController = Get.find();
    final PlayerController playerController = Get.find();
    final MainController mainController = Get.find();

    return Container(
      color: Colors.black.withOpacity(0.95), // Solid/Dark background to cover content
      child: Obx(() {
        if (musicController.isSearching.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }
        
        if (musicController.searchResults.isEmpty) {
             // If query is empty or no results
             if (mainController.searchInputController.text.isEmpty) {
                 return const Center(child: Text("Type to search...", style: TextStyle(color: Colors.white54)));
             }
             return Center(
               child: Text(
                 musicController.searchErrorMessage.value.isNotEmpty 
                     ? musicController.searchErrorMessage.value 
                     : "No results found",
                 style: const TextStyle(color: Colors.white70),
               ),
             );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: musicController.searchResults.length + 1, // +1 for spacing at bottom
          itemBuilder: (context, index) {
            if (index == musicController.searchResults.length) {
                return const SizedBox(height: 100); // Space for mini player
            }
            final track = musicController.searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: GestureDetector(
                onTap: () {
                  playerController.playTrack(track);
                  mainController.toggleSearch();
                },
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
                          errorWidget: (context, url, error) => const Icon(Icons.music_note, color: Colors.white),
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
                          mainController.toggleSearch(); 
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
