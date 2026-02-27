class MeetingRoomDetailsResponse {
  final bool status;
  final MeetingRoomDetails? data;

  MeetingRoomDetailsResponse({
    required this.status,
    this.data,
  });

  factory MeetingRoomDetailsResponse.fromJson(Map<String, dynamic> json) {
    return MeetingRoomDetailsResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? MeetingRoomDetails.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class MeetingRoomDetails {
  final int id;
  final int centerId;
  final int categoryId;
  final int calendarId;
  final String name;
  final String roomType;
  final int seater;
  final int floor;
  final String description;
  final int companyId;
  final String pricePerHour;
  final String bufferType;
  final int bufferTime;
  final int isActive;
  final String slotStartTime;
  final String slotEndTime;
  final int slotDuration;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final List<String> imageUrls;
  final List<AvailableSlot> availableSlots;
  final MeetingRoomCenter? center;
  final MeetingRoomCompany? company;
  final Category? category;
  final List<Amenity> amenities;
  final List<Booking> bookings;
  final List<MeetingRoomImage> images;

  MeetingRoomDetails({
    required this.id,
    required this.centerId,
    required this.categoryId,
    required this.calendarId,
    required this.name,
    required this.roomType,
    required this.seater,
    required this.floor,
    required this.description,
    required this.companyId,
    required this.pricePerHour,
    required this.bufferType,
    required this.bufferTime,
    required this.isActive,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.slotDuration,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.imageUrls,
    required this.availableSlots,
    this.center,
    this.company,
    this.category,
    required this.amenities,
    required this.bookings,
    required this.images,
  });

  factory MeetingRoomDetails.fromJson(Map<String, dynamic> json) {
    return MeetingRoomDetails(
      id: json['id'] ?? 0,
      centerId: json['center_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      calendarId: json['calendar_id'] ?? 0,
      name: json['name'] ?? '',
      roomType: json['room_type'] ?? '',
      seater: json['seater'] ?? 0,
      floor: json['floor'] ?? 0,
      description: json['description'] ?? '',
      companyId: json['company_id'] ?? 0,
      pricePerHour: json['price_per_hour'] ?? '0.00',
      bufferType: json['buffer_type'] ?? '',
      bufferTime: json['buffer_time'] ?? 0,
      isActive: json['is_active'] ?? 0,
      slotStartTime: json['slot_start_time'] ?? '',
      slotEndTime: json['slot_end_time'] ?? '',
      slotDuration: json['slot_duration'] ?? 30,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      availableSlots: json['available_slots'] != null
          ? (json['available_slots'] as List)
              .map((slot) => AvailableSlot.fromJson(slot))
              .toList()
          : [],
      center: json['center'] != null
          ? MeetingRoomCenter.fromJson(json['center'])
          : null,
      company: json['company'] != null
          ? MeetingRoomCompany.fromJson(json['company'])
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List)
              .map((amenity) => Amenity.fromJson(amenity))
              .toList()
          : [],
      bookings: json['bookings'] != null
          ? (json['bookings'] as List)
              .map((booking) => Booking.fromJson(booking))
              .toList()
          : [],
      images: json['images'] != null
          ? (json['images'] as List)
              .map((image) => MeetingRoomImage.fromJson(image))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_id': centerId,
      'category_id': categoryId,
      'calendar_id': calendarId,
      'name': name,
      'room_type': roomType,
      'seater': seater,
      'floor': floor,
      'description': description,
      'company_id': companyId,
      'price_per_hour': pricePerHour,
      'buffer_type': bufferType,
      'buffer_time': bufferTime,
      'is_active': isActive,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'slot_duration': slotDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'image_urls': imageUrls,
      'available_slots': availableSlots.map((slot) => slot.toJson()).toList(),
      'center': center?.toJson(),
      'company': company?.toJson(),
      'category': category?.toJson(),
      'amenities': amenities.map((amenity) => amenity.toJson()).toList(),
      'bookings': bookings.map((booking) => booking.toJson()).toList(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }
}

class AvailableSlot {
  final String date;
  final String start;
  final String end;
  final String status; // 'available' or 'booked'

  AvailableSlot({
    required this.date,
    required this.start,
    required this.end,
    required this.status,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      date: json['date'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start': start,
      'end': end,
      'status': status,
    };
  }

  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
}

class MeetingRoomCenter {
  final int id;
  final String centerName;
  final String buildingName;
  final String centerCode;
  final String centerType;
  final String address;
  final int cityId;
  final int facilityManagerId;
  final int numberOfFloors;
  final int seatsPerFloor;
  final int totalSeats;
  final bool status;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  MeetingRoomCenter({
    required this.id,
    required this.centerName,
    required this.buildingName,
    required this.centerCode,
    required this.centerType,
    required this.address,
    required this.cityId,
    required this.facilityManagerId,
    required this.numberOfFloors,
    required this.seatsPerFloor,
    required this.totalSeats,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory MeetingRoomCenter.fromJson(Map<String, dynamic> json) {
    return MeetingRoomCenter(
      id: json['id'] ?? 0,
      centerName: json['center_name'] ?? '',
      buildingName: json['building_name'] ?? '',
      centerCode: json['center_code'] ?? '',
      centerType: json['center_type'] ?? '',
      address: json['address'] ?? '',
      cityId: json['city_id'] ?? 0,
      facilityManagerId: json['facility_manager_id'] ?? 0,
      numberOfFloors: json['number_of_floors'] ?? 0,
      seatsPerFloor: json['seats_per_floor'] ?? 0,
      totalSeats: json['total_seats'] ?? 0,
      status: json['status'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'building_name': buildingName,
      'center_code': centerCode,
      'center_type': centerType,
      'address': address,
      'city_id': cityId,
      'facility_manager_id': facilityManagerId,
      'number_of_floors': numberOfFloors,
      'seats_per_floor': seatsPerFloor,
      'total_seats': totalSeats,
      'status': status,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}

class MeetingRoomCompany {
  final int id;
  final String zohoAccountId;
  final String companyName;
  final String companyCode;
  final String? industryType;
  final String website;
  final String? registeredAddress;
  final String? city;
  final String? state;
  final String? pincode;
  final int countryId;
  final String? clientSpocEmail;
  final String? clientSpocPhone;
  final int clientType;
  final String? startDate;
  final String? endDate;
  final bool status;
  final int isHeadquarter;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  MeetingRoomCompany({
    required this.id,
    required this.zohoAccountId,
    required this.companyName,
    required this.companyCode,
    this.industryType,
    required this.website,
    this.registeredAddress,
    this.city,
    this.state,
    this.pincode,
    required this.countryId,
    this.clientSpocEmail,
    this.clientSpocPhone,
    required this.clientType,
    this.startDate,
    this.endDate,
    required this.status,
    required this.isHeadquarter,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory MeetingRoomCompany.fromJson(Map<String, dynamic> json) {
    return MeetingRoomCompany(
      id: json['id'] ?? 0,
      zohoAccountId: json['zoho_account_id'] ?? '',
      companyName: json['company_name'] ?? '',
      companyCode: json['company_code'] ?? '',
      industryType: json['industry_type'],
      website: json['website'] ?? '',
      registeredAddress: json['registered_address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      countryId: json['country_id'] ?? 0,
      clientSpocEmail: json['client_spoc_email'],
      clientSpocPhone: json['client_spoc_phone'],
      clientType: json['client_type'] ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'] ?? false,
      isHeadquarter: json['is_headquarter'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoho_account_id': zohoAccountId,
      'company_name': companyName,
      'company_code': companyCode,
      'industry_type': industryType,
      'website': website,
      'registered_address': registeredAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country_id': countryId,
      'client_spoc_email': clientSpocEmail,
      'client_spoc_phone': clientSpocPhone,
      'client_type': clientType,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'is_headquarter': isHeadquarter,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Amenity {
  final int id;
  final String name;
  final String? icon;
  final String description;
  final String createdAt;
  final String updatedAt;
  final AmenityPivot? pivot;

  Amenity({
    required this.id,
    required this.name,
    this.icon,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      pivot: json['pivot'] != null ? AmenityPivot.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot?.toJson(),
    };
  }
}

class AmenityPivot {
  final int meetingRoomId;
  final int amenityId;

  AmenityPivot({
    required this.meetingRoomId,
    required this.amenityId,
  });

  factory AmenityPivot.fromJson(Map<String, dynamic> json) {
    return AmenityPivot(
      meetingRoomId: json['meeting_room_id'] ?? 0,
      amenityId: json['amenity_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting_room_id': meetingRoomId,
      'amenity_id': amenityId,
    };
  }
}

class Booking {
  // Since bookings array is empty in the example, creating a basic structure
  // You can expand this based on actual booking data structure
  final int? id;
  final Map<String, dynamic>? data;

  Booking({
    this.id,
    this.data,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      data: json,
    );
  }

  Map<String, dynamic> toJson() {
    return data ?? {'id': id};
  }
}

class MeetingRoomImage {
  final int id;
  final int meetingRoomId;
  final String imagePath;
  final String createdAt;
  final String updatedAt;

  MeetingRoomImage({
    required this.id,
    required this.meetingRoomId,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeetingRoomImage.fromJson(Map<String, dynamic> json) {
    return MeetingRoomImage(
      id: json['id'] ?? 0,
      meetingRoomId: json['meeting_room_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_room_id': meetingRoomId,
      'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

