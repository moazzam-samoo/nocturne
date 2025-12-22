import 'package:get/get.dart';
import '../../data/providers/jamendo_provider.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../domain/usecases/get_music.dart';
import '../../domain/usecases/search_music.dart';
import 'music_controller.dart';
import 'player_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut(() => JamendoProvider());

    // Repositories
    Get.lazyPut(() => MusicRepositoryImpl(provider: Get.find()));

    // UseCases
    Get.lazyPut(() => GetTrendingMusic(Get.find<MusicRepositoryImpl>()));
    Get.lazyPut(() => GetRegionalMusic(Get.find<MusicRepositoryImpl>()));
    Get.lazyPut(() => SearchMusic(Get.find<MusicRepositoryImpl>()));

    // Controllers
    Get.put(MusicController(
      getTrendingMusic: Get.find(),
      getRegionalMusic: Get.find(),
      searchMusicUseCase: Get.find(),
    ));
    Get.put(PlayerController());
  }
}
