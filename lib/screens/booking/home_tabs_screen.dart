import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/auth_controller.dart';
import '../../app/controllers/meeting_room_controller.dart';
import 'booking_tab.dart';
import 'qr_scanner_tab.dart';

class RoomTabsScreen extends StatefulWidget {
  const RoomTabsScreen({super.key});

  @override
  State<RoomTabsScreen> createState() => _RoomTabsScreenState();
}

class _RoomTabsScreenState extends State<RoomTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus when tapping outside input fields
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF202344),
        shape: const Border(
          bottom: BorderSide.none,
        ),
        title: Obx(() {
          final meetingRoomController = Get.find<MeetingRoomController>();
          final roomName = meetingRoomController.meetingRoomDetails.value?.name ?? 'Meeting Room';
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/launcher_Icon.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Incuspaze Meeting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
              Text(
                roomName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.logout),
                SizedBox(height: 2),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            onPressed: () async {
              final authController = Get.find<AuthController>();
              await authController.logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              icon: Icon(Icons.event_available),
              text: 'Book Room',
            ),
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: 'Check in',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const BookingTab(),
          Obx(() {
            final authController = Get.find<AuthController>();
            // Get meeting room ID from AuthController (stored during login)
            final meetingRoomId = authController.meetingRoomId.value;
            if (meetingRoomId == 0) {
              // Fallback to MeetingRoomController if not available in AuthController
              final meetingRoomController = Get.find<MeetingRoomController>();
              final fallbackId = meetingRoomController.meetingRoomDetails.value?.id ?? 0;
              return QRScannerTab(meetingRoomId: fallbackId.toString());
            }
            return QRScannerTab(meetingRoomId: meetingRoomId.toString());
          }),
        ],
      ),
      ),
    );
  }
}
