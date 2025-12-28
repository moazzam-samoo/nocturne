import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../backend/domain/entities/track.dart';
import '../../../backend/domain/repositories/music_repository.dart';
import '../../../backend/services/notification_service.dart';
import '../../../backend/services/storage_service.dart';

class MusicController extends GetxController {
  final MusicRepository repository;
  final NotificationService _notificationService = NotificationService();
  final Map<int, CancelToken> _activeDownloads = {};

  MusicController({required this.repository});
  
  // Observables
  var tracks = <Track>[].obs;
  var searchResults = <Track>[].obs; // Separate list for search results
  var isLoading = true.obs;
  var isSearching = false.obs; // Loading state for search
  var errorMessage = ''.obs;
  var searchErrorMessage = ''.obs; // Error message for search
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
     
     // Always try to dismiss the notification first for immediate feedback
     _notificationService.cancelNotification(notificationId);
     
     if (_activeDownloads.containsKey(notificationId)) {
        print('MusicController: Found active download for $notificationId. Cancelling...');
        _activeDownloads[notificationId]?.cancel('User cancelled');
        _activeDownloads.remove(notificationId);
        Get.snackbar('Cancelled', 'Download cancelled by user');
     } else {
        print('MusicController: No active download found for $notificationId. Active IDs: ${_activeDownloads.keys}');
     }
  }

  Future<void> fetchTracksByCategory() async {
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
      searchResults.clear();
      return;
    }
    
    try {
      isSearching(true);
      searchErrorMessage('');
      var result = await repository.searchTracks(query);
      if (result.isNotEmpty) {
        searchResults.assignAll(result);
      } else {
        searchErrorMessage('No tracks found for "$query"');
        searchResults.clear();
      }
    } catch (e) {
      searchErrorMessage(e.toString());
    } finally {
      isSearching(false);
    }
  }

  Future<void> downloadTrack(Track track) async {
    final notificationId = track.id.hashCode;
    final cancelToken = CancelToken();
    _activeDownloads[notificationId] = cancelToken;
    print('MusicController: Starting download for ${track.name}, notificationId: $notificationId');

    // Use /storage/emulated/0/Music/SM Music as default
    String baseDir = '/storage/emulated/0/Music/Nocturne';
    final dir = Directory(baseDir);
    // Sanitize filename to avoid filesystem issues
    final sanitizedFileName = track.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    String savePath = '${dir.path}/$sanitizedFileName.mp3';
    
    try {
      // Request permissions based on Android version
      if (Platform.isAndroid) {
         Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,  // < 13
          Permission.audio,    // >= 13
          Permission.notification,
        ].request();
        
        bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;
        bool audioGranted = statuses[Permission.audio]?.isGranted ?? false;
        
        if (!storageGranted && !audioGranted) {
           if (await Permission.manageExternalStorage.status.isDenied) {
              await Permission.manageExternalStorage.request();
           }
        }
      }

      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          print('MusicController: Direct creation failed: $e. Falling back to public Music folder.');
        }
      }

      // Check if file already exists and delete it to prevent PathExistsException
      final file = File(savePath);
      if (await file.exists()) {
        try {
          await file.delete();
          print('MusicController: Deleted existing file at $savePath');
        } catch (e) {
          print('MusicController: Check/Delete failed: $e');
          // Fallback: If delete fails (permission denied), create a unique filename
          print('MusicController: Generating unique filename due to delete failure.');
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          savePath = '${dir.path}/${sanitizedFileName}_$timestamp.mp3';
        }
      }
      
      Get.snackbar('Downloading', 'Downloading ${track.name}...');
      
      try {
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
      } catch (e) {
        // Retry logic: If download failed (likely PathExistsException), try with unique name
        print('MusicController: Primary download failed: $e. Retrying with unique filename...');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savePath = '${dir.path}/${sanitizedFileName}_$timestamp.mp3';
        
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
      }
      
      print('MusicController: Download finished for $notificationId');
      _activeDownloads.remove(notificationId);
      
      // Explicitly cancel progress notification
      _notificationService.cancelNotification(notificationId);
      
      // Show completion
      _notificationService.showDownloadCompleteNotification(
        notificationId,
        track.name
      );
      
      Get.snackbar('Success', 'Saved to Downloads/Nocturne');
      // Add to persistent storage
      Get.find<StorageService>().addDownload(track);
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
