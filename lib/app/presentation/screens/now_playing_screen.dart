import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart'; // LoopMode
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/glass_container.dart';
// import 'lyrics_screen.dart'; // Removing lyrics screen import

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with SingleTickerProviderStateMixin {
  final PlayerController playerController = Get.find();
  final MusicController musicController = Get.find();
  
  late AnimationController _animationController;
  Worker? _isPlayingWorker;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Sync animation with playback state safely
    _isPlayingWorker = ever(playerController.isPlaying, (playing) {
      if (!mounted) return; // Prevent crash if widget is defunct
      if (playing) {
        if (!_animationController.isAnimating) {
          _animationController.repeat();
        }
      } else {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
      }
    });

    // Initial check
    if (playerController.isPlaying.value) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _isPlayingWorker?.dispose(); // Dispose GetX worker
    _animationController.dispose(); // Dispose animation controller
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/app_logo.png', width: 24, height: 24),
              const SizedBox(width: 8),
              const Text('SM Music', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          centerTitle: true,
          actions: [
             // Favorites Button
             Obx(() {
                final track = playerController.currentTrack.value;
                if (track == null) return const SizedBox();
                final favoritesController = Get.put(FavoritesController()); // Ensure it's available
                final isFav = favoritesController.isFavorite(track);
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
                  onPressed: () => favoritesController.toggleFavorite(track),
                );
             }),
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 20),
                      _buildRotatingArtwork()
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .moveY(begin: 20, end: 0, duration: 600.ms),
                      const SizedBox(height: 30),
                      _buildTrackInfo()
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0),
                      const SizedBox(height: 20),
                      _buildProgressBar()
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0),
                       const SizedBox(height: 10),
                      _buildControls()
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0),
                       const SizedBox(height: 20),
                       _buildInfoPanel()
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .moveY(begin: 20, end: 0),
                    ],
                  ),
                ),
              ),
            );
          }
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
               child: Container(
                 width: 280,
                 height: 280,
                 decoration: const BoxDecoration(
                   shape: BoxShape.circle,
                 ),
                 child: ClipOval(
                   child: Image.network(
                     track.albumImage, 
                     fit: BoxFit.cover,
                     errorBuilder: (context, error, stackTrace) => Image.asset(
                       'assets/images/music_placeholder.png', 
                       fit: BoxFit.cover,
                     ),
                   ),
                 ),
               ),
               builder: (context, child) {
                 return Transform.rotate(
                   angle: _animationController.value * 2 * math.pi,
                   child: child,
                 );
               },
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
  
  Widget _buildInfoPanel() {
    return Obx(() {
      final track = playerController.currentTrack.value;
      if (track == null) return const SizedBox();

      return GlassContainer(
        width: double.infinity,
        height: 100,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildInfoItem('Album', track.album.isNotEmpty ? track.album : 'Single'),
               _buildVerticalDivider(),
               _buildInfoItem('Year', track.year.isNotEmpty ? track.year : '2024'),
               _buildVerticalDivider(),
               _buildInfoItem('Genre', track.genre.isNotEmpty ? track.genre : 'Pop'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
           constraints: const BoxConstraints(maxWidth: 80),
           child: Text(
             value, 
             maxLines: 1, 
             overflow: TextOverflow.ellipsis,
             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
           ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white24,
    );
  }
}
