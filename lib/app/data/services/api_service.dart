import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../models/meeting_room_models.dart';
import '../api/api_endpoint.dart';

class ApiService {
  // Login endpoint (password-based)
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.login);
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        // Handle error response
        throw Exception(
          responseData['message'] ?? 'Failed to login',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Logout endpoint
  Future<LogoutResponse> logout({
    required String token,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.logout);
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: '',
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LogoutResponse.fromJson(responseData);
      } else {
        // Handle error response
        throw Exception(
          responseData['message'] ?? 'Failed to logout',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Check-in endpoint
  Future<CheckInResponse> checkIn({
    required String token,
    // required String qrKey,
    String? qrKey,           // optional
    String? accessCode,
    required String meetingRoomId,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.checkIn);
      
      final request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // // Add form fields
      // request.fields['qr_key'] = qrKey;
      // request.fields['meeting_room_id'] = meetingRoomId;

      // Add form fields
      if (qrKey != null) {
        request.fields['qr_key'] = qrKey;
      }
      if (accessCode != null) {
        request.fields['access_code'] = accessCode;
      }
      request.fields['meeting_room_id'] = meetingRoomId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CheckInResponse.fromJson(responseData);
      } else {
        // Handle error response
        throw Exception(
          responseData['message'] ?? 'Failed to check in',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get meeting room details
  Future<MeetingRoomDetailsResponse> getMeetingRoomDetails({
    required String token,
    required int meetingRoomId,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.getMeetingRoomDetails(meetingRoomId));
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return MeetingRoomDetailsResponse.fromJson(responseData);
      } else {
        // Handle error response
        throw Exception(
          responseData['message'] ?? 'Failed to fetch meeting room details',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

