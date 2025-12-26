import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import '../controllers/main_controller.dart';
import 'search_screen.dart';
import 'trending_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import '../widgets/mini_player.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(MainController());
    
    final List<Widget> screens = [
      HomeScreen(),
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
            Color(0xFF0F0F0F), // Deep black-ish 
            Color(0xFF1A0B1A), // Subtle purple tint
            Color(0xFF000000), 
          ],
        ),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        title: const Text('SM Music', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        backgroundColor: Colors.transparent,
                        centerTitle: false,
                        pinned: true,
                        floating: true,
                        snap: true,
                        elevation: 0,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search), 
                            onPressed: () => Get.to(() => const SearchScreen(), transition: Transition.leftToRightWithFade)
                          ),
                          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                        ],
                        bottom: const TabBar(
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
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: screens,
                ),
              ),
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
