import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/meeting_room_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      debugPrint('🔧 Initializing bindings...');

      // Services
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);

      // Controllers
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      Get.lazyPut<MeetingRoomController>(() => MeetingRoomController(), fenix: true);

      debugPrint('✅ Bindings initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Fatal error in InitialBinding: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

