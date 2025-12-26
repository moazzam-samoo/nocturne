import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';

class MusicController extends GetxController {
  final MusicRepository repository;

  MusicController({required this.repository});
  
  // Observables
  var tracks = <Track>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedCategoryIndex = 0.obs; // 0: Indian, 1: Hollywood (International)

  @override
  void onInit() {
    super.onInit();
    fetchTracksByCategory();
  }

  void switchCategory(int index) {
    if (selectedCategoryIndex.value == index) return;
    selectedCategoryIndex.value = index;
    fetchTracksByCategory();
  }

  void fetchTracksByCategory() async {
    String tags = selectedCategoryIndex.value == 0 ? 'Latest Bollywood' : 'English Hit';
    
    try {
      isLoading(true);
      errorMessage('');
      var result = await repository.getTracks(limit: 50, tags: tags);
      if (result.isNotEmpty) {
        tracks.assignAll(result);
      } else {
        errorMessage('No tracks found.');
        tracks.clear();
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void search(String query) async {
    if (query.isEmpty) {
      fetchTracksByCategory();
      return;
    }
    
    try {
      isLoading(true);
      errorMessage('');
      var result = await repository.searchTracks(query);
      if (result.isNotEmpty) {
        tracks.assignAll(result);
      } else {
        errorMessage('No tracks found for "$query"');
        tracks.clear();
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadTrack(Track track) async {
    try {
      // Simple permission request for storage (may vary by Android version)
      var status = await Permission.storage.request();
      
      // On Android 13+, storage permission isn't needed for public downloads in some ways, 
      // but let's check general access or manage external storage if needed. 
      // For simplicity/compatibility:
      if (status.isDenied) {
         // Try audio permission for Android 13
         await Permission.audio.request();
      }

      final dir = Directory('/storage/emulated/0/Download/JM Music');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final savePath = '${dir.path}/${track.name}.mp3';
      
      Get.snackbar('Downloading', 'Downloading ${track.name}...');
      
      await Dio().download(track.audioUrl, savePath);
      
      Get.snackbar('Success', 'Saved to Downloads/JM Music');
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e');
    }
  }
}
