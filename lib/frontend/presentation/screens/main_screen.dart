import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added for potential use
import 'home_screen.dart';
import '../controllers/main_controller.dart';
import '../controllers/music_controller.dart'; // Added for search call
// import 'search_screen.dart'; // Removed
import 'trending_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/search_results_overlay.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are ready
    final MainController mainController = Get.put(MainController());
    // MusicController is already permanently loaded in InitialBinding
    final MusicController musicController = Get.find<MusicController>(); 

    final List<Widget> screens = [
      const HomeScreen(),
      TrendingScreen(),
      FavoritesScreen(),
      DownloadsScreen(),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0C29), // Deep dark purple/black
            Color(0xFF302B63), // Dark violet/blue
            Color(0xFF24243E), // Dark slate blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: mainController.isSearchExpanded.value
                ? TextField(
                    key: const ValueKey('searchField'),
                    controller: mainController.searchInputController,
                    focusNode: mainController.searchFocusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Search songs...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => musicController.search(val),
                  )
                : const Text('Nocturne', key: ValueKey('appTitle'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          )),
          centerTitle: false,
          actions: [
            Obx(() => IconButton(
              icon: Icon(mainController.isSearchExpanded.value ? Icons.close : Icons.search),
              onPressed: () {
                 if (mainController.isSearchExpanded.value) {
                   mainController.toggleSearch();
                   musicController.search(''); 
                 } else {
                   mainController.toggleSearch();
                 }
              },
            )),
            Obx(() => !mainController.isSearchExpanded.value 
               ? IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
               : const SizedBox.shrink()),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Obx(() => mainController.isSearchExpanded.value 
              ? const SizedBox.shrink()
              : TabBar(
                  controller: mainController.tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.pinkAccent,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'All Songs'),
                    Tab(text: 'Favorites'),
                    Tab(text: 'Downloads'),
                  ],
                ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: mainController.tabController,
              children: screens
            ),
            
            // Search Results Overlay
            Obx(() => mainController.isSearchExpanded.value
              ? const Positioned.fill(
                  child: SearchResultsOverlay(),
                )
              : const SizedBox.shrink()
            ),

            // Mini Player
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}
