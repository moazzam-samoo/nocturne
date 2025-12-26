import 'package:get/get.dart';
import '../../data/providers/saavn_provider.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Providers
    Get.lazyPut<SaavnProvider>(() => SaavnProvider());

    // 2. Repositories
    Get.lazyPut<MusicRepositoryImpl>(
        () => MusicRepositoryImpl(provider: Get.find<SaavnProvider>()));

    // 3. Controllers
    Get.put<PlayerController>(PlayerController()); // Put permanent as Player is global
    Get.lazyPut<MusicController>(
        () => MusicController(repository: Get.find<MusicRepositoryImpl>()));
  }
}
