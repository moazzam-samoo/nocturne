import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../services/notification_service.dart';

class MusicController extends GetxController {
  final MusicRepository repository;
  final NotificationService _notificationService = NotificationService();

  MusicController({required this.repository});
  
  // Observables
  var tracks = <Track>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedCategoryIndex = 0.obs; // 0: Indian, 1: Hollywood (International)

  @override
  void onInit() {
    super.onInit();
    _notificationService.init(); // Initialize notifications
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
      var status = await Permission.storage.request();
      
      // Request notification permission for Android 13+
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      if (status.isDenied) {
         await Permission.audio.request();
      }

      final dir = Directory('/storage/emulated/0/Download/JM Music');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final savePath = '${dir.path}/${track.name}.mp3';
      
      Get.snackbar('Downloading', 'Downloading ${track.name}...');
      
      // Use a unique ID for notification based on track hash or random
      final notificationId = track.id.hashCode;
      
      await Dio().download(
        track.audioUrl, 
        savePath,
        onReceiveProgress: (received, total) {
           if (total != -1) {
             int progress = ((received / total) * 100).toInt();
             _notificationService.showProgressNotification(
               notificationId,
               'Downloading ${track.name}',
               '$progress%',
               progress,
               100
             );
           }
        }
      );
      
      // Show completion
      _notificationService.showCompletionNotification(
        notificationId,
        'Download Complete',
        '${track.name} has been saved.'
      );
      
      Get.snackbar('Success', 'Saved to Downloads/JM Music');
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e');
      // Ideally cancel or show error notification
      _notificationService.cancelNotification(track.id.hashCode);
    }
  }
}
