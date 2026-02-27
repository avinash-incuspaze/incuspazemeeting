// Removed OtpResponse as we're using password-based login now

class LogoutResponse {
  final bool status;
  final String message;
  final dynamic data;

  LogoutResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

class AuthResponse {
  final bool status;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AuthData {
  final String token;
  final String tokenType;
  final UserData? userData;
  final int? centerId;
  final int? meetingRoomId;
  final String? deviceUuid;

  AuthData({
    required this.token,
    required this.tokenType,
    this.userData,
    this.centerId,
    this.meetingRoomId,
    this.deviceUuid,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      userData: json['data'] != null ? UserData.fromJson(json['data']) : null,
      centerId: json['center_id'],
      meetingRoomId: json['meeting_room_id'],
      deviceUuid: json['device_uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'data': userData?.toJson(),
      'center_id': centerId,
      'meeting_room_id': meetingRoomId,
      'device_uuid': deviceUuid,
    };
  }
}

class UserData {
  final int id;
  final String? displayId;
  final int? companyId;
  final String userType;
  final String? username;
  final String email;
  final int isEmailVerified;
  final String? emailVerifiedAt;
  final String? countryCode;
  final String? phone;
  final int isLoggedIn;
  final int isCenterSelected;
  final String? centerSelectedAt;
  final String? deviceType;
  final String? verificationKey;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? emailHash;
  final String? password;
  final List<Role>? roles;
  final UserProfile? userProfile;
  final MeetingRoomDevice? meetingRoomDevice;

  UserData({
    required this.id,
    this.displayId,
    this.companyId,
    required this.userType,
    this.username,
    required this.email,
    required this.isEmailVerified,
    this.emailVerifiedAt,
    this.countryCode,
    this.phone,
    required this.isLoggedIn,
    required this.isCenterSelected,
    this.centerSelectedAt,
    this.deviceType,
    this.verificationKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.emailHash,
    this.password,
    this.roles,
    this.userProfile,
    this.meetingRoomDevice,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      displayId: json['display_id'],
      companyId: json['company_id'],
      userType: json['user_type'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      isEmailVerified: json['is_email_verified'] ?? 0,
      emailVerifiedAt: json['email_verified_at'],
      countryCode: json['country_code'],
      phone: json['phone'],
      isLoggedIn: json['is_logged_in'] ?? 0,
      isCenterSelected: json['is_center_selected'] ?? 0,
      centerSelectedAt: json['center_selected_at'],
      deviceType: json['device_type'],
      verificationKey: json['verification_key'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      emailHash: json['email_hash'],
      password: json['password'],
      roles: json['roles'] != null
          ? (json['roles'] as List).map((role) => Role.fromJson(role)).toList()
          : null,
      userProfile: json['user_profile'] != null
          ? UserProfile.fromJson(json['user_profile'])
          : null,
      meetingRoomDevice: json['meeting_room_device'] != null
          ? MeetingRoomDevice.fromJson(json['meeting_room_device'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_id': displayId,
      'company_id': companyId,
      'user_type': userType,
      'username': username,
      'email': email,
      'is_email_verified': isEmailVerified,
      'email_verified_at': emailVerifiedAt,
      'country_code': countryCode,
      'phone': phone,
      'is_logged_in': isLoggedIn,
      'is_center_selected': isCenterSelected,
      'center_selected_at': centerSelectedAt,
      'device_type': deviceType,
      'verification_key': verificationKey,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'email_hash': emailHash,
      'password': password,
      'roles': roles?.map((role) => role.toJson()).toList(),
      'user_profile': userProfile?.toJson(),
      'meeting_room_device': meetingRoomDevice?.toJson(),
    };
  }
}

class Role {
  final int id;
  final String name;
  final RolePivot? pivot;

  Role({
    required this.id,
    required this.name,
    this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      pivot: json['pivot'] != null ? RolePivot.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pivot': pivot?.toJson(),
    };
  }
}

class RolePivot {
  final String modelType;
  final int modelId;
  final int roleId;

  RolePivot({
    required this.modelType,
    required this.modelId,
    required this.roleId,
  });

  factory RolePivot.fromJson(Map<String, dynamic> json) {
    return RolePivot(
      modelType: json['model_type'] ?? '',
      modelId: json['model_id'] ?? 0,
      roleId: json['role_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_type': modelType,
      'model_id': modelId,
      'role_id': roleId,
    };
  }
}

class UserProfile {
  final int id;
  final int userId;
  final int centreId;
  final Center? center;

  UserProfile({
    required this.id,
    required this.userId,
    required this.centreId,
    this.center,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      centreId: json['centre_id'] ?? 0,
      center: json['center'] != null ? Center.fromJson(json['center']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'centre_id': centreId,
      'center': center?.toJson(),
    };
  }
}

class MeetingRoomDevice {
  final int id;
  final int userId;
  final int centerId;
  final int meetingRoomId;
  final String deviceUuid;
  final String status;
  final MeetingRoom? meetingRoom;

  MeetingRoomDevice({
    required this.id,
    required this.userId,
    required this.centerId,
    required this.meetingRoomId,
    required this.deviceUuid,
    required this.status,
    this.meetingRoom,
  });

  factory MeetingRoomDevice.fromJson(Map<String, dynamic> json) {
    return MeetingRoomDevice(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      centerId: json['center_id'] ?? 0,
      meetingRoomId: json['meeting_room_id'] ?? 0,
      deviceUuid: json['device_uuid'] ?? '',
      status: json['status'] ?? '',
      meetingRoom: json['meeting_room'] != null
          ? MeetingRoom.fromJson(json['meeting_room'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'center_id': centerId,
      'meeting_room_id': meetingRoomId,
      'device_uuid': deviceUuid,
      'status': status,
      'meeting_room': meetingRoom?.toJson(),
    };
  }
}

class MeetingRoom {
  final int id;
  final String name;
  final String roomType;
  final int seater;
  final int floor;
  final String description;
  final int isActive;

  MeetingRoom({
    required this.id,
    required this.name,
    required this.roomType,
    required this.seater,
    required this.floor,
    required this.description,
    required this.isActive,
  });

  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    return MeetingRoom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      roomType: json['room_type'] ?? '',
      seater: json['seater'] ?? 0,
      floor: json['floor'] ?? 0,
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room_type': roomType,
      'seater': seater,
      'floor': floor,
      'description': description,
      'is_active': isActive,
    };
  }
}

class Company {
  final int id;
  final String name;
  final String code;
  final String website;
  final String? clientSpocEmail;
  final String? clientSpocPhone;
  final String? startDate;
  final String? endDate;

  Company({
    required this.id,
    required this.name,
    required this.code,
    required this.website,
    this.clientSpocEmail,
    this.clientSpocPhone,
    this.startDate,
    this.endDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      website: json['website'] ?? '',
      clientSpocEmail: json['client_spoc_email'],
      clientSpocPhone: json['client_spoc_phone'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'website': website,
      'client_spoc_email': clientSpocEmail,
      'client_spoc_phone': clientSpocPhone,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class Profile {
  final String? profileImage;
  final String? gender;
  final String? dob;
  final int? clientType;

  Profile({
    this.profileImage,
    this.gender,
    this.dob,
    this.clientType,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profileImage: json['profile_image'],
      gender: json['gender'],
      dob: json['dob'],
      clientType: json['client_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_image': profileImage,
      'gender': gender,
      'dob': dob,
      'client_type': clientType,
    };
  }
}

class Center {
  final int id;
  final String centerName;
  final String centerCode;
  final String buildingName;
  final String address;
  final bool status;

  Center({
    required this.id,
    required this.centerName,
    required this.centerCode,
    required this.buildingName,
    required this.address,
    required this.status,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      id: json['id'] ?? 0,
      centerName: json['center_name'] ?? '',
      centerCode: json['center_code'] ?? '',
      buildingName: json['building_name'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'center_code': centerCode,
      'building_name': buildingName,
      'address': address,
      'status': status,
    };
  }
}

class City {
  final int id;
  final String name;
  final State? state;

  City({
    required this.id,
    required this.name,
    this.state,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      state: json['state'] != null ? State.fromJson(json['state']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state?.toJson(),
    };
  }
}

class State {
  final int id;
  final String name;
  final Country? country;

  State({
    required this.id,
    required this.name,
    this.country,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country?.toJson(),
    };
  }
}

class Country {
  final int id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CheckInResponse {
  final bool status;
  final String message;

  CheckInResponse({
    required this.status,
    required this.message,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}

