import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/presentation/bindings/initial_binding.dart';
import 'app/presentation/screens/main_screen.dart';

import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const JMMusicApp());
}

class JMMusicApp extends StatelessWidget {
  const JMMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nocturne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent, // Important for Glassmorphism background
        fontFamily: 'Outfit', // We'll need to ensure this font is loaded or use Google Fonts
      ),
      initialBinding: InitialBinding(),
      home: MainScreen(),
    );
  }
}
