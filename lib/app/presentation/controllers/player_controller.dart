import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
      if (playerState.processingState == ProcessingState.completed) {
        // Handle track completion logic implies auto-next or repeat
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
      if (currentTrack.value?.id == track.id) {
         if (isPlaying.value) {
           pause();
         } else {
           resume();
         }
         return;
      }
      
      currentTrack.value = track;
      
      // Setup AudioSource with Metadata for Notification
      final audioSource = AudioSource.uri(
        Uri.parse(track.audioUrl),
        tag: MediaItem(
          id: track.id,
          album: "JM Music",
          title: track.name,
          artist: track.artistName,
          artUri: Uri.parse(track.albumImage),
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
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

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
