import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart'; // LoopMode
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/glass_container.dart';
import 'lyrics_screen.dart'; // Will create next

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  final PlayerController playerController = Get.find();
  final MusicController musicController = Get.find();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Sync rotation with playback status
    ever(playerController.isPlaying, (playing) {
      if (playing) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });

    if (playerController.isPlaying.value) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
         decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E0249), 
            Color(0xFFA91079), 
            Color(0xFF570A57), 
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          // Removed top right menu as requested
          actions: [
             IconButton(
               icon: const Icon(Icons.download_rounded, color: Colors.white),
               onPressed: () {
                 if (playerController.currentTrack.value != null) {
                    musicController.downloadTrack(playerController.currentTrack.value!);
                 }
               },
             ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildRotatingArtwork().animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack),
                const SizedBox(height: 50),
                _buildTrackInfo().animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 30),
                _buildProgressBar().animate().fadeIn(delay: 400.ms),
                 const SizedBox(height: 20),
                _buildControls().animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
                 const Spacer(),
                 _buildLyricsButton().animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... _buildRotatingArtwork and _buildTrackInfo kept same ...

  Widget _buildControls() {
    return Obx(() {
       return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.shuffle, 
              color: playerController.isShuffleModeEnabled.value ? const Color(0xFFA91079) : Colors.white70,
            ),
            onPressed: playerController.toggleShuffle,
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
            onPressed: () => playerController.skipToPrevious(), 
          ),
          
          // Play/Pause Button - IMPROVED VISIBILITY
          GlassContainer(
            width: 75,
            height: 75,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA91079).withOpacity(0.8), // Solid Pink/Purple
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA91079).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: IconButton(
                icon: Icon(
                  playerController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {
                   if (playerController.isPlaying.value) {
                                        playerController.pause();
                      } else {
                        playerController.resume();
                      }
                },
              ),
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
             onPressed: () => playerController.skipToNext(), 
          ),
           IconButton(
            icon: Icon(
              playerController.loopMode.value == LoopMode.one ? Icons.repeat_one : Icons.repeat,
              color: playerController.loopMode.value != LoopMode.off ? const Color(0xFFA91079) : Colors.white70
            ),
            onPressed: playerController.cycleLoopMode,
          ),
        ],
      );
    });
  }

  // ... _buildLyricsButton kept same ...
  Widget _buildRotatingArtwork() {
    return Obx(() {
        final track = playerController.currentTrack.value;
        if (track == null) return const SizedBox();

        return Stack(
          alignment: Alignment.center,
          children: [
             // Outer Glow
             Container(
               width: 280,
               height: 280,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 boxShadow: [
                   BoxShadow(
                     color: const Color(0xFFA91079).withOpacity(0.5),
                     blurRadius: 50,
                     spreadRadius: 10,
                   )
                 ]
               ),
             ),
             // Rotating Image
             AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _animationController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                 width: 250,
                 height: 250,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white.withOpacity(0.2), width: 8),
                 ),
                 child: ClipOval(
                   child: CachedNetworkImage(
                      imageUrl: track.albumImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                 ),
              ),
            ),
          ],
        );
    });
  }

  Widget _buildTrackInfo() {
    return Obx(() {
      final track = playerController.currentTrack.value;
      if (track == null) return const SizedBox();

      return Column(
        children: [
          Text(
            track.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            track.artistName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final progress = playerController.progress.value;
      final total = playerController.totalDuration.value;
      final buffered = playerController.bufferedPosition.value;

      return ProgressBar(
        progress: progress,
        total: total,
        buffered: buffered,
        progressBarColor: const Color(0xFFA91079), // Pink
        baseBarColor: Colors.white.withOpacity(0.1),
        bufferedBarColor: Colors.white.withOpacity(0.1),
        thumbColor: Colors.white,
        barHeight: 5.0,
        thumbRadius: 8.0,
        timeLabelTextStyle: const TextStyle(color: Colors.white70),
        onSeek: (duration) {
          playerController.seek(duration);
        },
      );
    });
  }
  
  Widget _buildLyricsButton() {
     return GestureDetector(
       onTap: () => Get.to(() => const LyricsScreen()),
       child: GlassContainer(
         width: 150,
         height: 50,
         borderRadius: BorderRadius.circular(25),
         child: const Center(
           child: Text(
             "Lyrics",
             style: TextStyle(
               color: Colors.white,
               fontWeight: FontWeight.bold,
             ),
           ),
         ),
       ),
     );
  }
}
