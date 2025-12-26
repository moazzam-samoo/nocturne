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

    return Scaffold(
      body: Container(
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
        child: DefaultTabController(
          length: 4,
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: Obx(() => SliverAppBar(
                        // Animate title change? SliverAppBar title doesn't animate implicitly easily.
                        // Using AnimatedSwitcher in title.
                        title: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: mainController.isSearchExpanded.value
                              ? TextField(
                                  key: const ValueKey('searchField'), // Key for AnimatedSwitcher
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
                              : const Text('SM Music', key: ValueKey('appTitle'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                        backgroundColor: Colors.transparent, // Or semi-transparent
                        centerTitle: false,
                        pinned: true,
                        floating: true,
                        snap: true,
                        elevation: 0,
                        actions: [
                          IconButton(
                            icon: Icon(mainController.isSearchExpanded.value ? Icons.close : Icons.search),
                            onPressed: () {
                               if (mainController.isSearchExpanded.value) {
                                 // Close
                                 mainController.toggleSearch();
                                 musicController.search(''); // Clear results
                               } else {
                                 // Open
                                 mainController.toggleSearch();
                               }
                            },
                          ),
                          if (!mainController.isSearchExpanded.value)
                             IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                        ],
                        bottom: mainController.isSearchExpanded.value 
                            ? null // Hide Tabs when searching? Or keep them? User said "split in the search bar"
                            // If we keep tabs, the results overlay handles covering.
                            // But visually, if search takes over, tabs might be distracting.
                            // Let's keep tabs for now to strictly follow "split in search bar" without removing other elements effectively.
                            // Actually, keeping tabs means the "Expanded" header height stays.
                            : const TabBar(
                                isScrollable: true,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.pinkAccent,
                                indicatorWeight: 3,
                                labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                tabs: [
                                  Tab(text: 'Home'),
                                  Tab(text: 'Trending'),
                                  Tab(text: 'Favorites'),
                                  Tab(text: 'Downloads'),
                                ],
                              ),
                      )),
                    ),
                  ];
                },
                body: TabBarView(
                  // controller: mainController.tabController, // Explicit controller usage if we switched to explicit
                  // Wait, MainController init TabController with length 4. 
                  // DefaultTabController was used before.
                  // If using NestedScrollView + TabBarView, we need to ensure controller sync or use DefaultTabController.
                  // Previous code passed `controller: null` (implied DefaultTabController).
                  // Let's use the mainController's tabController to be safe or wrap in DefaultTabController.
                  // MainController now initializes TabController.
                  children: screens,
                ),
              ),
              
              // Search Results Overlay
              Obx(() => Positioned.fill(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + (mainController.isSearchExpanded.value ? 0 : kTextTabBarHeight), // Offset?
                // Actually, NestedScrollView header is dynamic.
                // If we put overlay on top of everything, we need to respect the header.
                // Safer approach: Use the body of NestedScrollView? No, that scrolls.
                // If we position fill, it covers the header too? Yes.
                // We want to cover the BODY.
                // But the header changes size.
                // A simple approach: Full screen overlay with margins?
                // Or just below the AppBar?
                // Since AppBar is pinned, we know its min height?
                // The SliverAppBar expands.
                // Let's try: SearchResultsOverlay covers everything BELOW the pinned appbar.
                // The pinned appbar height is roughly kToolbarHeight + status bar.
                 
                child: mainController.isSearchExpanded.value
                    ? Padding(
                        padding: EdgeInsets.only(top: mainController.isSearchExpanded.value ? 0 : kTextTabBarHeight), // Adjust padding based on tab bar visibility
                        child: const SearchResultsOverlay(),
                      )
                    : const SizedBox.shrink(),
              )),

              // Mini Player Positioned at the bottom
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MiniPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
