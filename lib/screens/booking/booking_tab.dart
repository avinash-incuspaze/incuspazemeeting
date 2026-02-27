import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../app/controllers/meeting_room_controller.dart';
import '../../app/data/models/meeting_room_models.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  final MeetingRoomController _meetingRoomController =
      Get.find<MeetingRoomController>();
  Timer? _refreshTimer;
  Timer? _timeTimer;
  final GlobalKey _currentSlotKey = GlobalKey();
  final ScrollController _slotScrollController = ScrollController();
  int? _lastScrolledToSlotIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMeetingRoomDetails();
      _startAutoRefresh();
      _startTimeUpdates();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _timeTimer?.cancel();
    _slotScrollController.dispose();
    super.dispose();
  }

  // Approximate width per slot chip (padding 20+20 + "00:00 - 00:00" text) + separator
  static const double _slotItemWidth = 150.0;
  static const double _slotSeparatorWidth = 12.0;

  void _scrollCurrentSlotToCenter(int currentSlotIndex) {
    if (!mounted) return;
    if (!_slotScrollController.hasClients) return;
    final viewportWidth = _slotScrollController.position.viewportDimension;
    final maxScroll = _slotScrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    // Offset so this index is centered: item start ≈ index * (item + separator)
    final itemStart = currentSlotIndex * (_slotItemWidth + _slotSeparatorWidth);
    final targetOffset = itemStart - viewportWidth / 2 + _slotItemWidth / 2;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);
    _slotScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _startTimeUpdates() {
    _timeTimer?.cancel();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  // Start automatic refresh timer to fetch real-time data
  void _startAutoRefresh() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();
    
    // Refresh every 30 seconds to get real-time slot updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('⏰ Auto-refreshing meeting room data...');
        _fetchMeetingRoomDetails(forceRefresh: true);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchMeetingRoomDetails({bool forceRefresh = false}) async {
    try {
      // Always fetch fresh data from API for real-time slot updates
      // Slots change in real-time, so we need the latest data every time
      debugPrint('🔄 Fetching fresh meeting room data from API for real-time slots...');
      await _meetingRoomController.fetchMeetingRoomDetails();
    } catch (e) {
      debugPrint('❌ Error fetching meeting room details: $e');
      // If fetch fails, we can still use cached data if available
      final existingData = _meetingRoomController.meetingRoomDetails.value;
      if (existingData != null) {
        debugPrint('⚠️ Using cached data due to fetch error');
      }
    }
  }

  // Get current date (today) in YYYY-MM-DD format
  String _getCurrentDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Check if there's a meeting in progress (if any slot is booked for current time)
  bool _isMeetingInProgress() {
    final details = _meetingRoomController.meetingRoomDetails.value;
    if (details == null) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentDate = _getCurrentDateString();

    // Check if current time falls within any booked slot
    for (var slot in details.availableSlots) {
      if (slot.date == currentDate && slot.isBooked) {
        // Check if current time is within this slot
        if (_isTimeInRange(currentTime, slot.start, slot.end)) {
          return true;
        }
      }
    }
    return false;
  }

  // Helper to check if time is in range
  bool _isTimeInRange(String time, String start, String end) {
    try {
      final timeParts = time.split(':');
      final startParts = start.split(':');
      final endParts = end.split(':');

      final timeMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    } catch (e) {
      return false;
    }
  }

  // Get index of the slot that contains current time, or next upcoming slot (for auto-scroll to center)
  int _getCurrentSlotIndex(List<AvailableSlot> allSlots) {
    if (allSlots.isEmpty) return 0;
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    for (int i = 0; i < allSlots.length; i++) {
      final slot = allSlots[i];
      if (_isTimeInRange(currentTime, slot.start, slot.end)) return i;
      // If slot is in future (current time before slot start), this is the next slot
      try {
        final startParts = slot.start.split(':');
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final timeParts = currentTime.split(':');
        final timeMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
        if (timeMinutes < startMinutes) return i;
      } catch (_) {}
    }
    return allSlots.length - 1; // all past: show last slot
  }

  // Check if a slot is in the past
  bool _isSlotInPast(AvailableSlot slot, String dateString) {
    try {
      final now = DateTime.now();
      
      // Parse the slot date
      final slotDateParts = dateString.split('-');
      if (slotDateParts.length != 3) {
        debugPrint('⚠️ Invalid date format: $dateString');
        return false;
      }
      final slotYear = int.parse(slotDateParts[0]);
      final slotMonth = int.parse(slotDateParts[1]);
      final slotDay = int.parse(slotDateParts[2]);
      
      // Parse the slot end time
      final endParts = slot.end.split(':');
      if (endParts.length != 2) {
        debugPrint('⚠️ Invalid time format: ${slot.end}');
        return false;
      }
      final slotEndHour = int.parse(endParts[0]);
      final slotEndMinute = int.parse(endParts[1]);
      
      // Create DateTime for slot end time (local time)
      final slotEndDateTime = DateTime(slotYear, slotMonth, slotDay, slotEndHour, slotEndMinute);
      
      // Compare with current time - slot is past if current time is after slot end time
      final isPast = now.isAfter(slotEndDateTime);
      
      return isPast;
    } catch (e) {
      debugPrint('❌ Error checking if slot is past: $e for slot ${slot.start}-${slot.end} on $dateString');
      return false;
    }
  }

  // Get slot color based on status and time
  // Priority: Booked (orange) > Past (grey) > Available (green)
  Color _getSlotBackgroundColor(AvailableSlot slot, String dateString) {
    // Debug: Log slot status for booked slots
    if (slot.status == 'booked' || slot.isBooked) {
      final isPast = _isSlotInPast(slot, slot.date);
      debugPrint('🔍 Booked slot: ${slot.start}-${slot.end} | status="${slot.status}" | isBooked=${slot.isBooked} | isPast=$isPast');
    }
    
    // Booked slots: orange (0xFFF37F20)
    if (slot.isBooked || slot.status.toLowerCase().trim() == 'booked') {
      return const Color(0xFFF37F20);
    }
    
    // Past slots: grey
    final isPast = _isSlotInPast(slot, slot.date);
    if (isPast) {
      return Colors.grey[400]!;
    }
    
    // Available: green
    return Colors.green[100]!;
  }

  // Get slot border color based on status and time
  // Priority: Booked (orange) > Past (grey) > Available (green)
  Color _getSlotBorderColor(AvailableSlot slot, String dateString) {
    if (slot.isBooked || slot.status.toLowerCase().trim() == 'booked') {
      return const Color(0xFFF37F20);
    }
    final isPast = _isSlotInPast(slot, slot.date);
    if (isPast) {
      return Colors.grey[500]!;
    }
    return Colors.green[400]!;
  }

  // Get slot text color based on status and time
  // Priority: Booked (orange) > Past (grey) > Available (green)
  Color _getSlotTextColor(AvailableSlot slot, String dateString) {
    if (slot.isBooked || slot.status.toLowerCase().trim() == 'booked') {
      return Colors.white;
    }
    final isPast = _isSlotInPast(slot, slot.date);
    if (isPast) {
      return Colors.grey[600]!;
    }
    return Colors.green[800]!;
  }

  // Build legend item widget
  Widget _buildLegendItem(Color backgroundColor, Color borderColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Get icon for amenity based on name
  IconData _getAmenityIcon(String amenityName) {
    final name = amenityName.toLowerCase();
    if (name.contains('wifi') || name.contains('wi-fi')) {
      return Icons.wifi;
    } else if (name.contains('projector')) {
      return Icons.airplay;
    } else if (name.contains('video') || name.contains('conference')) {
      return Icons.videocam;
    } else if (name.contains('phone')) {
      return Icons.phone;
    } else if (name.contains('coffee') || name.contains('cafe')) {
      return Icons.local_cafe;
    } else if (name.contains('seating') || name.contains('seat')) {
      return Icons.people;
    }
    return Icons.star;
  }

  // Get app store URL for QR code
  // Returns a URL that works for both Android and iOS
  // Note: For better cross-platform support, consider using a redirect service
  // that detects the platform and redirects accordingly
  String _getAppStoreUrl() {
    // Using Android Play Store URL
    // - Android: Opens Play Store directly
    // - iOS: Opens in browser, user can navigate to App Store
    // Alternative: Use a redirect service (e.g., Firebase Dynamic Links, Branch.io)
    // that automatically detects platform and redirects to:
    // - Android: https://play.google.com/store/apps/details?id=com.incuspaze
    // - iOS: https://apps.apple.com/in/app/incuspaze/id6751551115
    
    // For now, using Android URL. For production, set up a redirect service.
    return 'https://play.google.com/store/apps/details?id=com.incuspaze';
    
    // iOS App Store URL (alternative - use redirect service for both):
    // return 'https://apps.apple.com/in/app/incuspaze/id6751551115';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = _meetingRoomController.meetingRoomDetails.value;
      final isLoading = _meetingRoomController.isLoading.value;
      final selectedDateString = _getCurrentDateString();

      // Get all slots for current date (today only)
      List<AvailableSlot> allSlots = [];
      String displayDate = selectedDateString;
      
      if (details != null) {
        allSlots = _meetingRoomController.getAllSlotsForDate(selectedDateString);
        
        // If no slots for today, try to get slots for the first available date
        if (allSlots.isEmpty) {
          final firstDate = _meetingRoomController.getFirstAvailableDate();
          if (firstDate != null) {
            allSlots = _meetingRoomController.getAllSlotsForDate(firstDate);
            displayDate = firstDate;
          }
        }
      }

      // Get amenities
      final amenities = details?.amenities ?? [];

      // Get room name
      final roomName = details?.name ?? 'Loading...';

      // Get seater count
      final seaterCount = details?.seater ?? 0;
      
      // Debug info
      if (details != null) {
        debugPrint('🏢 Room: $roomName');
        debugPrint('📅 Selected date: $selectedDateString, Display date: $displayDate');
        debugPrint('⏰ Total slots: ${allSlots.length}');
        debugPrint('⭐ Amenities: ${amenities.length}');
        
        // Debug: Log all slot statuses to identify booked slots
        final bookedSlots = allSlots.where((s) => s.status.toLowerCase().trim() == 'booked' || s.isBooked).toList();
        debugPrint('📋 Booked slots found in filtered list: ${bookedSlots.length}');
        for (var slot in bookedSlots) {
          debugPrint('   ✅ Booked: ${slot.start}-${slot.end} | status="${slot.status}" | isBooked=${slot.isBooked}');
        }
        
        // Debug: Check ALL slots in the meeting room details (not filtered by date)
        final allSlotsInDetails = details.availableSlots;
        final allBookedSlots = allSlotsInDetails.where((s) => s.status.toLowerCase().trim() == 'booked' || s.isBooked).toList();
        debugPrint('📋 Total booked slots in API response: ${allBookedSlots.length}');
        for (var slot in allBookedSlots) {
          debugPrint('   📌 Booked: ${slot.start}-${slot.end} on ${slot.date} | status="${slot.status}" | isBooked=${slot.isBooked}');
        }
        
        // Log ALL slots for the selected date
        debugPrint('📅 All slots for date $displayDate (${allSlots.length} total):');
        for (var i = 0; i < allSlots.length; i++) {
          final slot = allSlots[i];
          debugPrint('   Slot[$i]: ${slot.start}-${slot.end} | status="${slot.status}" | isBooked=${slot.isBooked}');
        }
        
      }

      // Show error if there's an error message
      final errorMessage = _meetingRoomController.errorMessage.value;
      if (errorMessage.isNotEmpty && details == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading meeting room details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _fetchMeetingRoomDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37F20),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (isLoading && details == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF37F20)),
            ),
          ),
        );
      }
      
      // Show message if details is null but not loading
      if (details == null && !isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No meeting room data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _fetchMeetingRoomDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37F20),
                  ),
                  child: const Text('Load Meeting Room'),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _fetchMeetingRoomDetails(forceRefresh: true);
        },
        color: const Color(0xFFF37F20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content fits
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Two Column Layout with Vertical Divider
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Room Status, Room Info Card and Date/Time cards
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Status Card at Top Left
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                _isMeetingInProgress()
                                    ? Icons.event_busy
                                    : Icons.check_circle,
                                color: _isMeetingInProgress()
                                    ? Colors.red
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _isMeetingInProgress()
                                      ? 'Meeting in Progress'
                                      : 'Meeting room available now',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _isMeetingInProgress()
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Room Info Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFF37F20), const Color(0xFFF59A4D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF37F20).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.meeting_room,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        roomName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        seaterCount > 0
                                            ? 'Seating: $seaterCount • Available for booking'
                                            : 'Available for booking',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Current Date and Timestamp row (two cards)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4ED),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFFF37F20),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4ED),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        color: Color(0xFFF37F20),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Time',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat('hh:mm:ss a').format(DateTime.now()),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Available Amenities Card (moved to left column)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: const Color(0xFFF37F20),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Available Amenities',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              amenities.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'No amenities available',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: amenities.map((amenity) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF4ED),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xFFFFD4B3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getAmenityIcon(amenity.name),
                                                size: 16,
                                                color: const Color(0xFFF37F20),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                amenity.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFE66A0D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Vertical Divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.grey[300]!,
                        Colors.grey[300]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Right Column: QR Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Code Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    color: const Color(0xFFF37F20),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Scan to Open App',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              // QR Code Widget
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD4B3),
                                    width: 2,
                                  ),
                                ),
                                child: QrImageView(
                                  data: _getAppStoreUrl(),
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan this QR code with your phone\nto download the Incuspaze app',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.android,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Android',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.phone_iphone,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'iOS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Available Time Slots Card (full width)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: const Color(0xFFF37F20),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Available Time Slots',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    allSlots.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No slots available for selected date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final currentSlotIndex = _getCurrentSlotIndex(allSlots);
                                  final shouldScroll = _lastScrolledToSlotIndex != currentSlotIndex;
                                  if (shouldScroll) {
                                    _lastScrolledToSlotIndex = currentSlotIndex;
                                    // Wait for list to build and layout, then scroll horizontal list to center current slot
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Future.delayed(const Duration(milliseconds: 50), () {
                                          if (!mounted) return;
                                          _scrollCurrentSlotToCenter(currentSlotIndex);
                                        });
                                      });
                                    });
                                  }
                                  const double itemExtent = _slotItemWidth + _slotSeparatorWidth;
                                  return SizedBox(
                                    height: 60,
                                    child: ListView.builder(
                                      controller: _slotScrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: allSlots.length,
                                      itemExtent: itemExtent,
                                      itemBuilder: (context, index) {
                                        final slot = allSlots[index];
                                        final slotText = '${slot.start} - ${slot.end}';
                                        final isCurrentSlot = index == currentSlotIndex;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index < allSlots.length - 1
                                                ? _slotSeparatorWidth
                                                : 0,
                                          ),
                                          child: Container(
                                            key: isCurrentSlot ? _currentSlotKey : null,
                                            width: _slotItemWidth,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getSlotBackgroundColor(slot, displayDate),
                                              border: Border.all(
                                                color: _getSlotBorderColor(slot, displayDate),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                slotText,
                                                style: TextStyle(
                                                  color: _getSlotTextColor(slot, displayDate),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Color Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem(
                                    Colors.green[100]!,
                                    Colors.green[400]!,
                                    'Available',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildLegendItem(
                                    const Color(0xFFF37F20),
                                    const Color(0xFFF37F20),
                                    'Booked',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildLegendItem(
                                    Colors.grey[400]!,
                                    Colors.grey[500]!,
                                    'Past',
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
        ),
      );
    });
  }
}

