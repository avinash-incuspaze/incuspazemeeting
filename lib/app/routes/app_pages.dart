import 'package:get/get.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../screens/booking/home_tabs_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const AdminLoginScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const AdminLoginScreen(),
    ),
    GetPage(
      name: Routes.ROOMS,
      page: () => const RoomTabsScreen(),
    ),
  ];
}

