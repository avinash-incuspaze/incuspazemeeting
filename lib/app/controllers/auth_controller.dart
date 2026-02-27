import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/auth_models.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final Rx<UserData?> userData = Rx<UserData?>(null);
  final RxString token = ''.obs;
  final RxList<String> roles = <String>[].obs;
  final RxInt centerId = 0.obs;
  final RxInt meetingRoomId = 0.obs;
  final RxString deviceUuid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedAuthData();
  }

  // Load saved authentication data from shared preferences
  Future<void> _loadSavedAuthData() async {
    try {
      final savedToken = StorageService.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
      }

      final savedUserData = StorageService.getUserData();
      if (savedUserData != null && savedUserData.isNotEmpty) {
        try {
          final userDataMap = jsonDecode(savedUserData) as Map<String, dynamic>;
          userData.value = UserData.fromJson(userDataMap);
        } catch (e) {
          debugPrint('Error parsing saved user data: $e');
        }
      }

      final savedRoles = StorageService.getRoles();
      if (savedRoles != null) {
        roles.value = savedRoles;
      }

      final savedCenterId = StorageService.getCenterId();
      if (savedCenterId != null) {
        centerId.value = savedCenterId;
      }

      final savedMeetingRoomId = StorageService.getMeetingRoomId();
      if (savedMeetingRoomId != null) {
        meetingRoomId.value = savedMeetingRoomId;
      }

      final savedDeviceUuid = StorageService.getDeviceUuid();
      if (savedDeviceUuid != null && savedDeviceUuid.isNotEmpty) {
        deviceUuid.value = savedDeviceUuid;
      }

      // If user has a valid token, automatically navigate to rooms screen
      if (savedToken != null && savedToken.isNotEmpty) {
        // Use a small delay to ensure GetX navigation is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.currentRoute == Routes.INITIAL || Get.currentRoute == Routes.LOGIN) {
            Get.offAllNamed(Routes.ROOMS);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading saved auth data: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.status && response.data != null) {
        final authData = response.data!;
        
        // Store user data and token in memory
        userData.value = authData.userData;
        token.value = authData.token;
        
        // Extract roles from userData
        if (authData.userData?.roles != null) {
          roles.value = authData.userData!.roles!
              .map((role) => role.name)
              .toList();
        }
        
        // Store center and meeting room info
        if (authData.centerId != null) {
          centerId.value = authData.centerId!;
        }
        if (authData.meetingRoomId != null) {
          meetingRoomId.value = authData.meetingRoomId!;
        }
        if (authData.deviceUuid != null && authData.deviceUuid!.isNotEmpty) {
          deviceUuid.value = authData.deviceUuid!;
        }

        // Save to shared preferences
        await StorageService.saveToken(authData.token);

        if (authData.userData != null) {
          final userDataJson = jsonEncode(authData.userData!.toJson());
          await StorageService.saveUserData(userDataJson);
        }

        if (roles.isNotEmpty) {
          await StorageService.saveRoles(roles);
        }

        if (authData.centerId != null) {
          await StorageService.saveCenterId(authData.centerId!);
        }

        if (authData.meetingRoomId != null) {
          await StorageService.saveMeetingRoomId(authData.meetingRoomId!);
        }

        if (authData.deviceUuid != null && authData.deviceUuid!.isNotEmpty) {
          await StorageService.saveDeviceUuid(authData.deviceUuid!);
        }

        isLoading.value = false;

        // Navigate to rooms screen
        Get.offAllNamed(Routes.ROOMS);

        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to login: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API if token exists
      final currentToken = token.value;
      if (currentToken.isNotEmpty) {
        try {
          await _apiService.logout(token: currentToken);
        } catch (e) {
          // Even if API call fails, continue with local logout
          debugPrint('Logout API error (continuing with local logout): $e');
        }
      }

      // Clear from memory
      userData.value = null;
      token.value = '';
      roles.clear();
      centerId.value = 0;
      meetingRoomId.value = 0;
      deviceUuid.value = '';

      // Clear from shared preferences
      await StorageService.clearAuthData();

      isLoading.value = false;

      // Navigate to login screen
      Get.offAllNamed(Routes.INITIAL);

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      
      // Still clear local data even if there's an error
      userData.value = null;
      token.value = '';
      roles.clear();
      centerId.value = 0;
      meetingRoomId.value = 0;
      deviceUuid.value = '';
      await StorageService.clearAuthData();

      Get.offAllNamed(Routes.INITIAL);

      Get.snackbar(
        'Warning',
        'Logged out locally. ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF202344),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

