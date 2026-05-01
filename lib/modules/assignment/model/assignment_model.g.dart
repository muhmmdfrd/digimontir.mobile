// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String?,
  latitude: _stringToDouble(json['latitude']),
  longitude: _stringToDouble(json['longitude']),
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

Status _$StatusFromJson(Map<String, dynamic> json) =>
    Status(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

AssignedUser _$AssignedUserFromJson(Map<String, dynamic> json) => AssignedUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$AssignedUserToJson(AssignedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

Assignment _$AssignmentFromJson(Map<String, dynamic> json) => Assignment(
  id: (json['id'] as num).toInt(),
  adminId: (json['admin_id'] as num?)?.toInt(),
  technicianId: (json['technician_id'] as num?)?.toInt(),
  customerId: (json['customer_id'] as num?)?.toInt(),
  statusId: (json['status_id'] as num?)?.toInt(),
  descriptionByAdmin: json['description_by_admin'] as String?,
  latCheckIn: _stringToDouble(json['lat_check_in']),
  lngCheckIn: _stringToDouble(json['lng_check_in']),
  checkInPhotoPath: json['check_in_photo_url'] as String?,
  checkOutPhotoPath: json['check_out_photo_url'] as String?,
  latCheckOut: _stringToDouble(json['lat_check_out']),
  lngCheckOut: _stringToDouble(json['lng_check_out']),
  descriptionByTechnician: json['description_by_technician'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  reviewByAdmin: json['review_by_admin'] as String?,
  completedAt: json['completed_at'] as String?,
  closedAt: json['closed_at'] as String?,
  customer: json['customer'] == null
      ? null
      : Customer.fromJson(json['customer'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : Status.fromJson(json['status'] as Map<String, dynamic>),
  technician: json['technician'] == null
      ? null
      : AssignedUser.fromJson(json['technician'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AssignmentToJson(Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'admin_id': instance.adminId,
      'technician_id': instance.technicianId,
      'customer_id': instance.customerId,
      'status_id': instance.statusId,
      'description_by_admin': instance.descriptionByAdmin,
      'lat_check_in': instance.latCheckIn,
      'lng_check_in': instance.lngCheckIn,
      'check_in_photo_url': instance.checkInPhotoPath,
      'check_out_photo_url': instance.checkOutPhotoPath,
      'lat_check_out': instance.latCheckOut,
      'lng_check_out': instance.lngCheckOut,
      'description_by_technician': instance.descriptionByTechnician,
      'rating': instance.rating,
      'review_by_admin': instance.reviewByAdmin,
      'completed_at': instance.completedAt,
      'closed_at': instance.closedAt,
      'customer': instance.customer,
      'status': instance.status,
      'technician': instance.technician,
    };
