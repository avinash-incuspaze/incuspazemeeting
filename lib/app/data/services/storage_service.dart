import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyRoles = 'roles';
  static const String _keyCenterId = 'center_id';
  static const String _keyMeetingRoomId = 'meeting_room_id';
  static const String _keyDeviceUuid = 'device_uuid';
  static const String _keyMeetingRoomDetails = 'meeting_room_details';

  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<bool> saveToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<bool> deleteToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyToken);
  }

  // User data management (stored as JSON string)
  static Future<bool> saveUserData(String userDataJson) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyUserData, userDataJson);
  }

  static String? getUserData() {
    return _prefs?.getString(_keyUserData);
  }

  static Future<bool> deleteUserData() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyUserData);
  }

  // Center ID management
  static Future<bool> saveCenterId(int centerId) async {
    if (_prefs == null) await init();
    return await _prefs!.setInt(_keyCenterId, centerId);
  }

  static int? getCenterId() {
    return _prefs?.getInt(_keyCenterId);
  }

  static Future<bool> deleteCenterId() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyCenterId);
  }

  // Meeting Room ID management
  static Future<bool> saveMeetingRoomId(int meetingRoomId) async {
    if (_prefs == null) await init();
    return await _prefs!.setInt(_keyMeetingRoomId, meetingRoomId);
  }

  static int? getMeetingRoomId() {
    return _prefs?.getInt(_keyMeetingRoomId);
  }

  static Future<bool> deleteMeetingRoomId() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyMeetingRoomId);
  }

  // Device UUID management
  static Future<bool> saveDeviceUuid(String deviceUuid) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyDeviceUuid, deviceUuid);
  }

  static String? getDeviceUuid() {
    return _prefs?.getString(_keyDeviceUuid);
  }

  static Future<bool> deleteDeviceUuid() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyDeviceUuid);
  }

  // Roles management
  static Future<bool> saveRoles(List<String> roles) async {
    if (_prefs == null) await init();
    return await _prefs!.setStringList(_keyRoles, roles);
  }

  static List<String>? getRoles() {
    return _prefs?.getStringList(_keyRoles);
  }

  static Future<bool> deleteRoles() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyRoles);
  }

  // Clear all auth data
  static Future<bool> clearAuthData() async {
    if (_prefs == null) await init();
    await deleteToken();
    await deleteUserData();
    await deleteRoles();
    await deleteCenterId();
    await deleteMeetingRoomId();
    await deleteDeviceUuid();
    return true;
  }

  // Meeting Room Details management (stored as JSON string)
  static Future<bool> saveMeetingRoomDetails(String meetingRoomDetailsJson) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_keyMeetingRoomDetails, meetingRoomDetailsJson);
  }

  static String? getMeetingRoomDetails() {
    return _prefs?.getString(_keyMeetingRoomDetails);
  }

  static Future<bool> deleteMeetingRoomDetails() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_keyMeetingRoomDetails);
  }

  // Clear all auth data
  static Future<bool> clearAllData() async {
    if (_prefs == null) await init();
    await clearAuthData();
    await deleteMeetingRoomDetails();
    return true;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}

