import 'dart:io';
import 'package:get/get.dart';
import '../../../backend/domain/entities/track.dart';
import '../../../backend/services/storage_service.dart';
import 'player_controller.dart';
import 'music_controller.dart'; 

class DownloadsController extends GetxController {
  StorageService get _storage => Get.find<StorageService>();
  // ignore: unused_field
  MusicController get _musicController => Get.find<MusicController>();

  RxList<Track> get downloadedTracks => _storage.downloadedTracks;
  
  // We can add a method to verify file existence on init if we want to be robust
  // For now relying on stored metadata.

  void playDownloadedTrack(Track track) {
     if (Get.isRegistered<PlayerController>()) {
       Get.find<PlayerController>().playTrack(track);
     } else {
       Get.snackbar('Error', 'Player not ready');
     }
  }

  Future<void> deleteDownload(Track track) async {
    try {
      // 1. Resolve path logic (copied from MusicController for now, arguably should be in a shared helper)
       File? file;
       if (track.localPath != null && track.localPath!.isNotEmpty) {
          file = File(track.localPath!);
       } else {
          // Legacy fallback
          String baseDir = '/storage/emulated/0/Music/Nocturne';
          final sanitizedFileName = track.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
          file = File('$baseDir/$sanitizedFileName.mp3');
       }

       if (await file.exists()) {
         await file.delete();
         Get.snackbar('Deleted', '${track.name} deleted from device');
       } else {
         // Also try standard music dir if fallback failed? 
         Get.snackbar('Error', 'File not found on device');
       }

       // 2. Remove metadata
       _storage.removeDownload(track.id);

    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }
}
