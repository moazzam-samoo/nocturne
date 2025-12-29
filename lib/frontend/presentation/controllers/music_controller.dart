import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audiotags/audiotags.dart';
import '../../../backend/data/models/track_model.dart'; // Added missing import
import '../../../backend/domain/entities/track.dart';
import '../../../backend/domain/repositories/music_repository.dart';
import '../../../backend/services/notification_service.dart';
import '../../../backend/services/storage_service.dart';

class MusicController extends GetxController {
  final MusicRepository repository;
  final NotificationService _notificationService = NotificationService();
  final Map<int, CancelToken> _activeDownloads = {};
  static const platform = MethodChannel('com.jm_music/media_scanner');

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

  Future<Directory> _getDownloadDirectory() async {
    Directory? dir;
    
    // 1. Try public Music folder (Android) if possible
    if (Platform.isAndroid) {
      try {
        dir = Directory('/storage/emulated/0/Music/Nocturne');
        if (!await dir.exists()) {
           await dir.create(recursive: true);
        }
        print('MusicController: Using public Music directory: ${dir.path}');
        return dir;
      } catch (e) {
        print('MusicController: Failed to access public Music directory: $e. Falling back to app storage.');
      }
    }

    // 2. Fallback: Use path_provider
    try {
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory(); // App-specific external storage
      } else {
        dir = await getApplicationDocumentsDirectory(); // iOS/others
      }
      
      if (dir != null) {
         dir = Directory('${dir.path}/Nocturne'); // Subfolder
         if (!await dir.exists()) {
            await dir.create(recursive: true);
         }
         print('MusicController: Using fallback directory: ${dir.path}');
         return dir;
      }
    } catch (e) {
       print('MusicController: Path provider failed: $e');
    }

    throw Exception('Could not determine download directory');
  }

  Future<void> downloadTrack(Track track) async {
    final notificationId = track.id.hashCode;
    final cancelToken = CancelToken();
    _activeDownloads[notificationId] = cancelToken;
    print('MusicController: Starting download for ${track.name}, notificationId: $notificationId');

    try {
      // Request permissions based on Android version
      if (Platform.isAndroid) {
         Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,  // < 13
          Permission.audio,    // >= 13
          Permission.notification,
        ].request();
        
        // Check permissions (somewhat loose logic as we have fallbacks)
        bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;
        bool audioGranted = statuses[Permission.audio]?.isGranted ?? false;
        
        // Attempt manageExternalStorage if standard permissions fail and we might need it for public folder
        if (!storageGranted && !audioGranted) {
           if (await Permission.manageExternalStorage.status.isDenied) {
              // Only request if really needed? Let's try to proceed, maybe app-specific storage works.
              // But for public folder access on 11+, we might need it or media store.
              // Let's request it to be safe for user expectations.
              await Permission.manageExternalStorage.request();
           }
        }
      }

      final dir = await _getDownloadDirectory();

      
      // Sanitize filename
      final sanitizedFileName = track.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      String savePath = '${dir.path}/$sanitizedFileName.mp3';
      
      // Check for existing actual file
      final file = File(savePath);
      if (await file.exists()) {
          // Check if it's already in our DB too
          final storageService = Get.find<StorageService>();
          if (storageService.downloadedTracks.any((t) => t.localPath == savePath || t.id == track.id)) {
              Get.snackbar('Already Downloaded', 'This song is already in your downloads.');
              return;
          } else {
             // File exists but not in DB (edge case? or maybe just sync it now)
             // We can just add it to DB and return.
             print('MusicController: File exists but not in DB. Adding to DB.');
             
             final updatedTrack = TrackModel(
                id: track.id,
                name: track.name,
                artistName: track.artistName,
                albumImage: track.albumImage,
                audioUrl: track.audioUrl,
                duration: track.duration,
                album: track.album,
                year: track.year,
                genre: track.genre,
                releaseDate: track.releaseDate,
                popularity: track.popularity,
                hasLyrics: track.hasLyrics,
                localPath: savePath,
              );
              storageService.addDownload(updatedTrack);
              Get.snackbar('Success', 'Added existing file to downloads');
              return;
          }
      }
      
      Get.snackbar('Downloading', 'Downloading ${track.name}...');
      
      // --- Download Logic (Refactored to loop/retry once if needed) ---
      // We will try download logic. If it fails, we might retry with unique name (handled inside logic below)
      
      await _executeDownload(track.audioUrl, savePath, cancelToken, notificationId, track.name);
      
      print('MusicController: Download finished for $notificationId');
      _activeDownloads.remove(notificationId);
      
      // Explicitly cancel progress notification
      _notificationService.cancelNotification(notificationId);
      
      // Show completion
      _notificationService.showDownloadCompleteNotification(
        notificationId,
        track.name
      );
      
      Get.snackbar('Success', 'Saved to ${dir.path}');
      
      // Trigger Media Scan
      try {
        if (Platform.isAndroid) {
          await platform.invokeMethod('scanFile', {'path': savePath});
          print('MusicController: Media scan triggered for $savePath');
        }
      } catch (e) {
         print('MusicController: Media scan failed: $e');
      }

      // Create updated track with local path
      final updatedTrack = TrackModel(
        id: track.id,
        name: track.name,
        artistName: track.artistName,
        albumImage: track.albumImage,
        audioUrl: track.audioUrl,
        duration: track.duration,
        album: track.album,
        year: track.year,
        genre: track.genre,
        releaseDate: track.releaseDate,
        popularity: track.popularity,
        hasLyrics: track.hasLyrics,
        localPath: savePath, // Store the path!
      );

      // Add to persistent storage
      Get.find<StorageService>().addDownload(updatedTrack);

    } catch (e) {
      print('MusicController: Download error for $notificationId: $e');
      if (e is DioException && CancelToken.isCancel(e)) {
          print('MusicController: Download was CANCELLED for $notificationId');
          _activeDownloads.remove(notificationId);
      } else {
          print('MusicController: Download FAILED for $notificationId: $e');
          Get.snackbar('Error', 'Download failed: $e');
          _notificationService.cancelNotification(notificationId);
          _activeDownloads.remove(notificationId);
      }
    }
  }

  Future<void> _executeDownload(String url, String path, CancelToken cancelToken, int notificationId, String trackName) async {
     try {
        await Dio().download(
          url, 
          path,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
             if (cancelToken.isCancelled) return; 
             if (total != -1) {
               int progress = ((received / total) * 100).toInt();
               _notificationService.showProgressNotification(
                 notificationId,
                 'Downloading $trackName',
                 '$progress%',
                 progress,
                 100
               );
             }
          }
        );
     } catch (e) {
        // Retry with unique name if permission/file locked issue? 
        // Or if it was just network error, maybe not useful to rename. 
        // But fulfilling previous logic of retrying with timestamp:
        print('MusicController: Primary download failed: $e. Retrying with unique filename...');
        final dir = Directory(File(path).parent.path);
        // Re-sanitize name just in case, or parse from path
        final name = trackName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${dir.path}/${name}_$timestamp.mp3';
        
        await Dio().download(
          url, 
          newPath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
             if (cancelToken.isCancelled) return; 
             if (total != -1) {
               int progress = ((received / total) * 100).toInt();
               _notificationService.showProgressNotification(
                 notificationId,
                 'Downloading $trackName',
                 '$progress%',
                 progress,
                 100
               );
             }
          }
        );
     }
  }

  Future<void> _syncExistingDownloads() async {
     try {
       print('MusicController: Starting local file sync...');
       
       // Request permissions if not strictly granted? 
       // We'll trust the OS to handle repeated requests policy (or user denied).
       // We need at least one of these to work.
       Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.audio,
          Permission.manageExternalStorage,
       ].request();

       bool storageAccess = statuses[Permission.storage]?.isGranted ?? false;
       bool audioAccess = statuses[Permission.audio]?.isGranted ?? false; 
       bool manageAccess = statuses[Permission.manageExternalStorage]?.isGranted ?? false;

       if (storageAccess || audioAccess || manageAccess) {
           final dir = await _getDownloadDirectory();
           print('MusicController: Syncing from ${dir.path}');
           
           if (await dir.exists()) {
             final files = dir.listSync().where((e) => e.path.toLowerCase().endsWith('.mp3'));
             final storageService = Get.find<StorageService>();
             int newSyncedCount = 0;

             for (var entity in files) {
                if (entity is File) {
                   // Check if already in downloads
                   if (storageService.downloadedTracks.any((t) => t.localPath == entity.path)) {
                      continue;
                   }
                   
                   try {
                     // Read metadata using audiotags
                     Tag? tag = await AudioTags.read(entity.path);
                     
                     // Create track
                     final track = TrackModel(
                       id: entity.path.hashCode.toString(),
                       name: tag?.title ?? entity.path.split('/').last.replaceAll('.mp3', ''),
                       artistName: tag?.trackArtist ?? 'Unknown Artist',
                       albumImage: '', 
                       audioUrl: entity.path,
                       duration: tag?.duration ?? 0,
                       album: tag?.album ?? 'Unknown Album',
                       year: tag?.year?.toString() ?? '',
                       genre: tag?.genre ?? '',
                       releaseDate: '',
                       popularity: '0',
                       hasLyrics: false,
                       localPath: entity.path,
                     );
                     
                     storageService.addDownload(track);
                     newSyncedCount++;
                     print('MusicController: Synced local file: ${track.name}');
                     
                   } catch (e) {
                      print('MusicController: Failed to read metadata for ${entity.path}: $e');
                      // Fallback
                      final track = TrackModel(
                       id: entity.path.hashCode.toString(),
                       name: entity.path.split('/').last.replaceAll('.mp3', ''),
                       artistName: 'Unknown Artist',
                       albumImage: '',
                       audioUrl: entity.path,
                       duration: 0,
                       album: 'Unknown Album',
                       year: '',
                       genre: '',
                       releaseDate: '',
                       popularity: '0',
                       hasLyrics: false,
                       localPath: entity.path,
                     );
                     storageService.addDownload(track);
                     newSyncedCount++;
                   }
                }
             }
             
             if (newSyncedCount > 0) {
                Get.snackbar('Sync Complete', 'Found $newSyncedCount new downloaded songs');
             } else {
                // Optional: Uncomment to confirm it ran but found nothing
                // Get.snackbar('Sync', 'No new local files found', duration: const Duration(seconds: 1));
             }
           } else {
              print('MusicController: Directory does not exist');
           }
       } else {
          print('MusicController: Permissions denied for sync');
       }
     } catch (e) {
        print('MusicController: Sync failed: $e');
        Get.snackbar('Sync Error', 'Failed to scan local files: $e');
     }
  }
}
