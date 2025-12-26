import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    
    _createNotificationChannel();
  }
  
  Future<void> _createNotificationChannel() async {
     const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'download_channel', // id
      'Downloads', // title
      description: 'Used for showing download progress',
      importance: Importance.low, // Low importance suppresses sound/vibration for progress updates
      playSound: false,
    );
     
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> showProgressNotification(int id, String title, String body, int progress, int maxProgress) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'download_channel', 
            'Downloads',
            channelDescription: 'Show download progress',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            ongoing: true);
            
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
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
  
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
