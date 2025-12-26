import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../../services/notification_service.dart';

class MusicController extends GetxController {
  final MusicRepository repository;
  final NotificationService _notificationService = NotificationService();
  final Map<int, CancelToken> _activeDownloads = {};

  MusicController({required this.repository});
  
  // Observables
  var tracks = <Track>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedCategoryIndex = 0.obs; // 0: Indian, 1: Hollywood (International)

  @override
  void onInit() {
    super.onInit();
    _notificationService.init((response) { 
        print('MusicController: Notification Response: actionId=${response.actionId}, payload=${response.payload}');
        if (response.actionId == 'cancel_download') {
           print('MusicController: Cancel action detected');
           if (response.payload != null) {
              int? id = int.tryParse(response.payload!);
              print('MusicController: Cancelling download with id: $id');
              if (id != null) {
                 _cancelDownload(id);
              }
           }
        }
    });
    fetchTracksByCategory();
  }

  void switchCategory(int index) {
    if (selectedCategoryIndex.value == index) return;
    selectedCategoryIndex.value = index;
    fetchTracksByCategory();
  }
  
  void _cancelDownload(int notificationId) {
     print('MusicController: _cancelDownload called for $notificationId');
     if (_activeDownloads.containsKey(notificationId)) {
        print('MusicController: Found active download for $notificationId. Cancelling...');
        _activeDownloads[notificationId]?.cancel('User cancelled');
        _activeDownloads.remove(notificationId);
        _notificationService.cancelNotification(notificationId);
        Get.snackbar('Cancelled', 'Download cancelled by user');
     } else {
        print('MusicController: No active download found for $notificationId. Active IDs: ${_activeDownloads.keys}');
     }
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
    final notificationId = track.id.hashCode;
    final cancelToken = CancelToken();
    _activeDownloads[notificationId] = cancelToken;
    print('MusicController: Starting download for ${track.name}, notificationId: $notificationId');

    final dir = Directory('/storage/emulated/0/Download/SM Music');
    final savePath = '${dir.path}/${track.name}.mp3';
    
    try {
      var status = await Permission.storage.request();
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      if (status.isDenied) {
         await Permission.audio.request();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      Get.snackbar('Downloading', 'Downloading ${track.name}...');
      
      await Dio().download(
        track.audioUrl, 
        savePath,
        cancelToken: cancelToken,
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
      
      print('MusicController: Download finished for $notificationId');
      _activeDownloads.remove(notificationId);
      
      // Show completion
      _notificationService.showCompletionNotification(
        notificationId,
        'Download Complete',
        '${track.name} has been saved.'
      );
      
      Get.snackbar('Success', 'Saved to Downloads/SM Music');
    } catch (e) {
      print('MusicController: Download error for $notificationId: $e');
      
      // Clean up partial file if it exists and it was a cancellation or failure
      try {
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
          print('MusicController: Deleted partial file at $savePath');
        }
      } catch (cleanupError) {
        print('MusicController: Error cleaning up file: $cleanupError');
      }

      if (e is DioException && CancelToken.isCancel(e)) {
          print('MusicController: Download was CANCELLED for $notificationId');
          _activeDownloads.remove(notificationId);
          // Notification already handled in _cancelDownload
      } else {
          print('MusicController: Download FAILED for $notificationId: $e');
          Get.snackbar('Error', 'Download failed: $e');
          _notificationService.cancelNotification(notificationId);
          _activeDownloads.remove(notificationId);
      }
    }
  }
}
