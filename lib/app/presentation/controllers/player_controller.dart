import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../controllers/music_controller.dart';
import '../../domain/entities/track.dart';

class PlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Observables
  var currentTrack = Rxn<Track>();
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
      if (index != null) {
        final MusicController musicController = Get.find<MusicController>();
        if (index < musicController.tracks.length) {
          currentTrack.value = musicController.tracks[index];
        }
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
      final allTracks = musicController.tracks;
      final index = allTracks.indexWhere((t) => t.id == track.id);
      
      if (index == -1) return; // Should not happen

      // If playing the same track, just toggle play/pause
      if (currentTrack.value?.id == track.id) {
         if (isPlaying.value) {
           pause();
         } else {
           resume();
         }
         return;
      }
      
      // Create a playlist from all tracks
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: allTracks.map((t) {
          return AudioSource.uri(
            Uri.parse(t.audioUrl),
            tag: MediaItem(
              id: t.id,
              album: "SM Music",
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
