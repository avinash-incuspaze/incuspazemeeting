enum Environment {
  staging,
  main,
}

class ApiEndpoint {
  // Switch between staging and main server here
  static const Environment currentEnvironment = Environment.main;

  // Base URLs
  static const String _stagingBaseUrl = 'https://dev.incuspaze.com/backend/api'; //staging
  static const String _mainBaseUrl = 'https://app.incuspaze.com/backend/api'; //main

  // Get current base URL based on environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.main:
        return _mainBaseUrl;
    }
  }

  // Auth Endpoints
  static String get login => '$baseUrl/tablet/auth/login';
  static String get logout => '$baseUrl/logout';

  // Meeting Room Endpoints
  static String get checkIn => '$baseUrl/tablet/MeetingRoom/check-in';
  
  // Get meeting room details by ID
  static String getMeetingRoomDetails(int meetingRoomId) =>
      '$baseUrl/meeting-rooms/$meetingRoomId';
}

