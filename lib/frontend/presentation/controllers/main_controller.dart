import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/now_playing_screen.dart';

class MainController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  
  // Search State
  var isSearchExpanded = false.obs;
  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this); // Length matched to 4 tabs
  }

  @override
  void onClose() {
    tabController.dispose();
    searchInputController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (isSearchExpanded.value) {
      searchFocusNode.requestFocus();
    } else {
      clearSearch();
      searchFocusNode.unfocus();
    }
  }

  void clearSearch() {
    searchInputController.clear();
  }

  void goToPlayer() {
    Get.to(() => const NowPlayingScreen(), transition: Transition.downToUp);
  }
}
