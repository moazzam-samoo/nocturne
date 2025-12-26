import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback for notification actions
  Future<void> init(void Function(NotificationResponse) onNotificationResponse) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon'); // Use the generated SM Music icon

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification Response Received: id=${response.id}, actionId=${response.actionId}, payload=${response.payload}');
        onNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    
    _createNotificationChannel();
  }
  
  // Create a static method for background handling
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    print('Background Notification Response Received: id=${notificationResponse.id}, actionId=${notificationResponse.actionId}');
    // We could use a stream or a method channel here if we needed to talk to the main isolate
  }
  
  Future<void> _createNotificationChannel() async {
     const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'download_channel', // id
      'Downloads', // title
      description: 'Used for showing download progress',
      importance: Importance.low, 
      playSound: false,
    );
     
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> showProgressNotification(int id, String title, String body, int progress, int maxProgress) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'download_channel', 
            'Nocturne Downloads',
            channelDescription: 'Show download progress for Nocturne',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            ongoing: true,
            largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
            actions: [
              const AndroidNotificationAction(
                'cancel_download', 
                'Cancel',
                showsUserInterface: true,
                cancelNotification: true, // Allow OS to dismiss immediately
              ),
            ],
        );
            
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: id.toString(), // Pass ID as payload to identifying which download to cancel
    );
  }

  Future<void> showCompletionNotification(int id, String title, String body) async {
     final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'download_channel', 
            'Downloads',
            channelDescription: 'Show download success',
            importance: Importance.high,
            priority: Priority.high,
            onlyAlertOnce: false,
            showProgress: false,
            ongoing: false);
            
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  
  Future<void> showDownloadCompleteNotification(int id, String trackName) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'download_complete_channel', 
            'Nocturne Downloads Complete',
            channelDescription: 'Notifications for finished downloads',
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
        );
        
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _notificationsPlugin.show(
      id,
      'Download Completed',
      'Track $trackName is ready! Listen in Nocturne.',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
