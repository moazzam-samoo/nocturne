import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/track.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  var currentTrack = Rxn<Track>();
  var isPlaying = false.obs;
  var progress = Duration.zero.obs;
  var buffered = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to player state
    audioPlayer.playerStateStream.listen((playerState) {
      isPlaying.value = playerState.playing;
      if (playerState.processingState == ProcessingState.completed) {
        // Auto play next or stop (logic can be expanded)
        isPlaying.value = false;
        progress.value = Duration.zero;
      }
    });

    // Listen to position updates
    audioPlayer.positionStream.listen((position) {
      progress.value = position;
    });

    // Listen to buffered position
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      buffered.value = bufferedPosition;
    });

    // Listen to duration
    audioPlayer.durationStream.listen((duration) {
      totalDuration.value = duration ?? Duration.zero;
    });
  }

  Future<void> playTrack(Track track) async {
    try {
      currentTrack.value = track;
      if (track.audioUrl.isNotEmpty) {
        await audioPlayer.setUrl(track.audioUrl);
        play();
      }
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  void play() {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }
  
  void togglePlayPause() {
    if (isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
