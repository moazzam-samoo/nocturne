import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/now_playing_screen.dart';

class MainController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void goToPlayer() {
    Get.to(() => const NowPlayingScreen(), transition: Transition.downToUp);
  }
}
