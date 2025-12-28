import 'package:get/get.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../controllers/music_controller.dart';
import '../controllers/trending_controller.dart'; // Added missing import
import '../../../backend/domain/entities/track.dart';

class PlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Observables
  var currentTrack = Rxn<Track>();
  var currentQueue = <Track>[].obs; // Track the currently playing list
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var bufferedPosition = Duration.zero.obs;
  
  // Playback Mode Observables
  var isShuffleModeEnabled = false.obs;
  var loopMode = LoopMode.off.obs;

  @override
  void onInit() {
    print('PlayerController: onInit called');
    super.onInit();
    // Configure audio session
    try {
       final session = AudioSession.instance;
       session.then((s) => s.configure(const AudioSessionConfiguration.music()));
    } catch(e) {
       print('PlayerController: AudioSession error: $e');
    }
    
    // Listen to player state
    _audioPlayer.playerStateStream.listen((playerState) {
      isPlaying.value = playerState.playing;
    });

    // Listen to current item index to update currentTrack
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < currentQueue.length) {
         currentTrack.value = currentQueue[index];
      }
    });

    // Listen to position updates
    _audioPlayer.positionStream.listen((p) {
      progress.value = p;
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((d) {
      totalDuration.value = d ?? Duration.zero;
    });
    
    // Listen to buffered position
    _audioPlayer.bufferedPositionStream.listen((b) {
      bufferedPosition.value = b;
    });

    // Listen for player errors
    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
      Get.snackbar('Playback Error', '$e');
    });
  }

  Future<void> playTrack(Track track) async {
    try {
      final MusicController musicController = Get.find<MusicController>();
      List<Track> sourceList = [];

      // Determine the source context for the track
      // Check if it exists in the main category tracks
      if (musicController.tracks.any((t) => t.id == track.id)) {
        sourceList = musicController.tracks;
      } 
      // Check if it exists in search results
      else if (musicController.searchResults.any((t) => t.id == track.id)) {
        sourceList = musicController.searchResults;
      } 
      // Check if it exists in All Songs (Trending)
      else if (Get.isRegistered<TrendingController>() && 
               Get.find<TrendingController>().displayedTracks.any((t) => t.id == track.id)) {
        sourceList = Get.find<TrendingController>().displayedTracks;
      }
      // Fallback: Just play this single track
      else {
        sourceList = [track];
      }

      // Update the current queue reference
      currentQueue.assignAll(sourceList);

      final index = sourceList.indexWhere((t) => t.id == track.id);
      
      if (index == -1) return; 

      // Capture the currently playing ID BEFORE updating it
      final previousTrackId = currentTrack.value?.id;
      
      // Update current track so UI shows the new song
      currentTrack.value = track;

      // If playing the same track, just toggle play/pause
      // BUT only if we actually have an active player session
      if (previousTrackId == track.id && _audioPlayer.processingState != ProcessingState.idle) {
         if (isPlaying.value) {
           pause();
         } else {
           resume();
         }
         return;
      }
      
      // Create a playlist from sourceList
      final audioSources = await Future.wait(sourceList.map((t) async {
          // Check for local file first
          final sanitizedName = t.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
          // Check new Nocturne path
          final File localFile = File('/storage/emulated/0/Music/Nocturne/$sanitizedName.mp3');
          
          Uri audioUri;
          if (localFile.existsSync()) {
            int length = 0;
            try { length = await localFile.length(); } catch(_){}
            print('PlayerController: Found LOCAL file: ${localFile.path}, Size: $length bytes');
            
            if (length < 1024) { // Less than 1KB (likely failed download)
               print('PlayerController: File too small, deleting and using REMOTE.');
               try { await localFile.delete(); } catch (_) {}
               audioUri = Uri.parse(t.audioUrl);
            } else {
               audioUri = Uri.file(localFile.path);
            }
          } else {
             // Fallback to old SM Music path for legacy downloads
             final File legacyFile = File('/storage/emulated/0/Music/SM Music/$sanitizedName.mp3');
             if (legacyFile.existsSync()) {
                audioUri = Uri.file(legacyFile.path);
                print('PlayerController: Playing from LEGACY file: ${legacyFile.path}');
             } else {
                audioUri = Uri.parse(t.audioUrl);
                print('PlayerController: Playing from REMOTE url: ${t.audioUrl}');
             }
          }

          return AudioSource.uri(
            audioUri,
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'},
            tag: MediaItem(
              id: t.id,
              album: "Nocturne",
              title: t.name,
              artist: t.artistName,
              artUri: Uri.parse(t.albumImage),
            ),
          );
      }));

      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: audioSources,
      );

      _audioPlayer.playerStateStream.listen((state) {
         print('PlayerController: State Changed: ${state.processingState}, Playing: ${state.playing}');
      });

      await _audioPlayer.setAudioSource(playlist, initialIndex: index);
      _audioPlayer.play();
    } catch (e) {
      print("PlayerController: CRITICAL ERROR in playTrack: $e");
      Get.snackbar("Error", "Could not play track: $e");
    }
  }

  void resume() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }
  
  void toggleShuffle() {
    isShuffleModeEnabled.value = !isShuffleModeEnabled.value;
    _audioPlayer.setShuffleModeEnabled(isShuffleModeEnabled.value);
  }

  void cycleLoopMode() {
    if (loopMode.value == LoopMode.off) {
      loopMode.value = LoopMode.all;
    } else if (loopMode.value == LoopMode.all) {
      loopMode.value = LoopMode.one;
    } else {
      loopMode.value = LoopMode.off;
    }
    _audioPlayer.setLoopMode(loopMode.value);
  }

  Future<void> skipToNext() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> skipToPrevious() async {
    await _audioPlayer.seekToPrevious();
  }
  
  void togglePlayPause() {
    if (isPlaying.value) {
      pause();
    } else {
      resume();
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
