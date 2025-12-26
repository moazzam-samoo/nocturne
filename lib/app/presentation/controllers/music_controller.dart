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
        if (response.actionId == 'cancel_download') {
           if (response.payload != null) {
              int? id = int.tryParse(response.payload!);
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
     if (_activeDownloads.containsKey(notificationId)) {
        _activeDownloads[notificationId]?.cancel('User cancelled');
        _activeDownloads.remove(notificationId);
        _notificationService.cancelNotification(notificationId);
        Get.snackbar('Cancelled', 'Download cancelled by user');
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

    try {
      var status = await Permission.storage.request();
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
      
      _activeDownloads.remove(notificationId);
      
      // Show completion
      _notificationService.showCompletionNotification(
        notificationId,
        'Download Complete',
        '${track.name} has been saved.'
      );
      
      Get.snackbar('Success', 'Saved to Downloads/JM Music');
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
          // Already handled cleanup in _cancelDownload usually, but ensure removal
          _activeDownloads.remove(notificationId);
          // Notification already cancelled
      } else {
          Get.snackbar('Error', 'Download failed: $e');
          _notificationService.cancelNotification(notificationId);
          _activeDownloads.remove(notificationId);
      }
    }
  }
}
