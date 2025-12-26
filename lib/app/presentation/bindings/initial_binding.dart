import 'package:get/get.dart';
import '../../data/providers/saavn_provider.dart';
import '../../services/storage_service.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../domain/repositories/music_repository.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 0. Services (Storage)
    Get.putAsync<StorageService>(() => StorageService().init());

    // 1. Providers
    Get.lazyPut<SaavnProvider>(() => SaavnProvider());

    // 2. Repositories
    // Bind interface to implementation
    Get.lazyPut<MusicRepository>(
        () => MusicRepositoryImpl(provider: Get.find<SaavnProvider>()));

    // 3. Controllers
    Get.put<PlayerController>(PlayerController()); // Put permanent as Player is global
    Get.put<MusicController>(
        MusicController(repository: Get.find<MusicRepository>()), permanent: true);
        
    // 4. Feature Controllers (Lazy load or put here)
    // Main layout controller
    // Note: MainController, FavoritesController, etc., are usually put() inside their screen's build or a separate AppBinding.
    // However, since we use indexed stack, let's lazy put them so they are available when tabs are switched.
  }
}
