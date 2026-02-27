import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/meeting_room_models.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';
import '../controllers/auth_controller.dart';

class MeetingRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final Rx<MeetingRoomDetails?> meetingRoomDetails = Rx<MeetingRoomDetails?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedMeetingRoomDetails();
  }

  // Load saved meeting room details from shared preferences
  Future<void> _loadSavedMeetingRoomDetails() async {
    try {
      final savedDetails = StorageService.getMeetingRoomDetails();
      if (savedDetails != null && savedDetails.isNotEmpty) {
        try {
          final detailsMap = jsonDecode(savedDetails) as Map<String, dynamic>;
          meetingRoomDetails.value = MeetingRoomDetails.fromJson(detailsMap);
        } catch (e) {
          debugPrint('Error parsing saved meeting room details: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading saved meeting room details: $e');
    }
  }

  // Fetch meeting room details from API
  Future<void> fetchMeetingRoomDetails({int? meetingRoomId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get meeting room ID from parameter or from auth controller
      final authController = Get.find<AuthController>();
      final roomId = meetingRoomId ?? authController.meetingRoomId.value;

      debugPrint('🔍 Fetching meeting room details for ID: $roomId');

      if (roomId == 0) {
        debugPrint('❌ Meeting room ID is 0, checking auth data...');
        debugPrint('   Auth meeting room ID: ${authController.meetingRoomId.value}');
        throw Exception('Meeting room ID not found. Please login again.');
      }

      // Get token from auth controller
      final token = authController.token.value;
      if (token.isEmpty) {
        debugPrint('❌ Token is empty');
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('🔑 Token found, length: ${token.length}');

      final response = await _apiService.getMeetingRoomDetails(
        token: token,
        meetingRoomId: roomId,
      );

      if (response.status && response.data != null) {
        meetingRoomDetails.value = response.data;

        // Save to shared preferences
        final detailsJson = jsonEncode(response.data!.toJson());
        await StorageService.saveMeetingRoomDetails(detailsJson);

        isLoading.value = false;
        debugPrint('✅ Meeting room details loaded: ${response.data!.name}');
        debugPrint('✅ Available slots count: ${response.data!.availableSlots.length}');
        debugPrint('✅ Amenities count: ${response.data!.amenities.length}');
        
        // Debug: Check booked slots in the response
        final bookedSlots = response.data!.availableSlots.where((s) => s.status.toLowerCase().trim() == 'booked' || s.isBooked).toList();
        debugPrint('🔍 Booked slots in API response: ${bookedSlots.length}');
        for (var slot in bookedSlots) {
          debugPrint('   📌 Booked slot: ${slot.start}-${slot.end} on ${slot.date} | status="${slot.status}" | isBooked=${slot.isBooked}');
        }
        
        // Debug: Show all slot statuses
        final statusCounts = <String, int>{};
        for (var slot in response.data!.availableSlots) {
          statusCounts[slot.status] = (statusCounts[slot.status] ?? 0) + 1;
        }
        debugPrint('📊 Slot status breakdown: $statusCounts');
      } else {
        isLoading.value = false;
        errorMessage.value = 'Failed to fetch meeting room details';
        Get.snackbar(
          'Error',
          'Failed to fetch meeting room details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch meeting room details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Get available slots for a specific date
  List<AvailableSlot> getAvailableSlotsForDate(String date) {
    if (meetingRoomDetails.value == null) {
      debugPrint('⚠️ Meeting room details is null');
      return [];
    }
    final slots = meetingRoomDetails.value!.availableSlots
        .where((slot) => slot.date == date && slot.isAvailable)
        .toList();
    debugPrint('📅 Looking for slots on $date, found ${slots.length} available slots');
    if (slots.isEmpty) {
      // Debug: show all dates in slots
      final allDates = meetingRoomDetails.value!.availableSlots
          .map((s) => s.date)
          .toSet()
          .toList();
      debugPrint('📅 Available dates in response: $allDates');
    }
    return slots;
  }

  // Get first available date from slots (fallback if today has no slots)
  String? getFirstAvailableDate() {
    if (meetingRoomDetails.value == null) return null;
    final dates = meetingRoomDetails.value!.availableSlots
        .map((slot) => slot.date)
        .toSet()
        .toList();
    if (dates.isNotEmpty) {
      dates.sort();
      return dates.first;
    }
    return null;
  }

  // Get booked slots for a specific date
  List<AvailableSlot> getBookedSlotsForDate(String date) {
    if (meetingRoomDetails.value == null) return [];
    return meetingRoomDetails.value!.availableSlots
        .where((slot) => slot.date == date && slot.isBooked)
        .toList();
  }

  // Get all slots for a specific date
  List<AvailableSlot> getAllSlotsForDate(String date) {
    if (meetingRoomDetails.value == null) return [];
    return meetingRoomDetails.value!.availableSlots
        .where((slot) => slot.date == date)
        .toList();
  }

  // Get amenities list
  List<Amenity> get amenities {
    if (meetingRoomDetails.value == null) return [];
    return meetingRoomDetails.value!.amenities;
  }

  // Get center information
  MeetingRoomCenter? get center {
    return meetingRoomDetails.value?.center;
  }

  // Get company information
  MeetingRoomCompany? get company {
    return meetingRoomDetails.value?.company;
  }

  // Get category information
  Category? get category {
    return meetingRoomDetails.value?.category;
  }

  // Get images
  List<MeetingRoomImage> get images {
    if (meetingRoomDetails.value == null) return [];
    return meetingRoomDetails.value!.images;
  }

  // Get image URLs
  List<String> get imageUrls {
    if (meetingRoomDetails.value == null) return [];
    return meetingRoomDetails.value!.imageUrls;
  }

  // Clear meeting room details
  Future<void> clearMeetingRoomDetails() async {
    meetingRoomDetails.value = null;
    errorMessage.value = '';
    await StorageService.deleteMeetingRoomDetails();
  }

  // Refresh meeting room details
  Future<void> refreshMeetingRoomDetails({int? meetingRoomId}) async {
    await fetchMeetingRoomDetails(meetingRoomId: meetingRoomId);
  }
}

