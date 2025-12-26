import 'package:get/get.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../controllers/music_controller.dart';
import '../../domain/entities/track.dart';

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
    super.onInit();
    
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
      // Fallback: Just play this single track
      else {
        sourceList = [track];
      }

      // Update the current queue reference
      currentQueue.assignAll(sourceList);

      final index = sourceList.indexWhere((t) => t.id == track.id);
      
      if (index == -1) return; 

      // If playing the same track, just toggle play/pause
      if (currentTrack.value?.id == track.id) {
         if (isPlaying.value) {
           pause();
         } else {
           resume();
         }
         return;
      }
      
      // Create a playlist from sourceList
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: sourceList.map((t) {
          // Check for local file first
          final sanitizedName = t.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
          // Check new Nocturne path
          final File localFile = File('/storage/emulated/0/Music/Nocturne/$sanitizedName.mp3');
          
          Uri audioUri;
          if (localFile.existsSync()) {
            audioUri = Uri.file(localFile.path);
            print('PlayerController: Playing from LOCAL file: ${localFile.path}');
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
            tag: MediaItem(
              id: t.id,
              album: "Nocturne",
              title: t.name,
              artist: t.artistName,
              artUri: Uri.parse(t.albumImage),
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(playlist, initialIndex: index);
      _audioPlayer.play();
    } catch (e) {
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

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
