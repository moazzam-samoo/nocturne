import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../controllers/player_controller.dart';
import '../widgets/glass_container.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find();

    return Obx(() {
      final track = playerController.currentTrack.value;
      if (track == null) return const SizedBox();

      return Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: track.albumImage,
              fit: BoxFit.cover,
            ),
          ),
          // Blur Overlay
           Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/app_logo.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  const Text("Lyrics", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                   children: [
                    GlassContainer(
                       width: double.infinity,
                       height: 600,
                       padding: const EdgeInsets.all(20),
                       child: const Center(
                         child: Text(
                           "Synchronized lyrics are not available in the public SM Music API.\n\nImagine beautiful scrolling text here matching the rhythm of the music.",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 22,
                             fontWeight: FontWeight.w600,
                             height: 1.5,
                             fontFamily: 'Outfit',
                           ),
                         ),
                       ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
