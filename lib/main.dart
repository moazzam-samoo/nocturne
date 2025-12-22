import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/presentation/bindings/initial_binding.dart';
import 'app/presentation/pages/home_page.dart';
import 'app/presentation/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Classic Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: InitialBinding(),
      home: const HomePage(),
    );
  }
}
