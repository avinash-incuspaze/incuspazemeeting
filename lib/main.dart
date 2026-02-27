import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/services/storage_service.dart';

void main() async {
  // Run in a Zone to catch all errors
  runZonedGuarded(() async {
    // Ensure Flutter widgets are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set landscape orientation for tablet-only app
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Add error handling for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('❌ Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    // Add error handling for async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('❌ Platform Error: $error');
      debugPrint('Stack trace: $stack');
      return true;
    };

    try {
      debugPrint('🚀 Starting app initialization...');

      // Initialize StorageService
      await StorageService.init();
      debugPrint('✅ StorageService initialized');

      runApp(const MyApp());
      debugPrint('✅ App started successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during app initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      runApp(const MyApp());
    }
  }, (error, stack) {
    debugPrint('❌ Uncaught error in Zone: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      debugPrint('🎨 Building MyApp widget...');

      // Check if user is already logged in to determine initial route
      final isLoggedIn = StorageService.isLoggedIn();
      final initialRoute = isLoggedIn ? Routes.ROOMS : Routes.INITIAL;

      return GetMaterialApp(
        title: 'Incuspaze Meeting Room Booking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF37F20)),
          useMaterial3: true,
        ),
        initialBinding: InitialBinding(),
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          try {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox(),
            );
          } catch (e) {
            debugPrint('❌ Error in builder: $e');
            return const Scaffold(
              body: Center(
                child: Text('Error loading app'),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error building MyApp: $e');
      debugPrint('Stack trace: $stackTrace');
      return MaterialApp(
        title: 'Incuspaze Meeting',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
