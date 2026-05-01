import 'package:json_annotation/json_annotation.dart';

part 'assignment_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Customer {
  final int id;
  final String name;
  final String phone;
  final String? address;
  @JsonKey(fromJson: _stringToDouble)
  final double? latitude;
  @JsonKey(fromJson: _stringToDouble)
  final double? longitude;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Status {
  final int id;
  final String name;

  const Status({required this.id, required this.name});

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssignedUser {
  final int id;
  final String name;
  final String email;

  const AssignedUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) =>
      _$AssignedUserFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedUserToJson(this);
}

double? _stringToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Assignment {
  final int id;
  final int? adminId;
  final int? technicianId;
  final int? customerId;
  final int? statusId;
  final String? descriptionByAdmin;
  @JsonKey(fromJson: _stringToDouble)
  final double? latCheckIn;
  @JsonKey(fromJson: _stringToDouble)
  final double? lngCheckIn;
  @JsonKey(name: 'check_in_photo_url')
  final String? checkInPhotoPath;
  @JsonKey(name: 'check_out_photo_url')
  final String? checkOutPhotoPath;
  @JsonKey(fromJson: _stringToDouble)
  final double? latCheckOut;
  @JsonKey(fromJson: _stringToDouble)
  final double? lngCheckOut;
  final String? descriptionByTechnician;
  final int? rating;
  final String? reviewByAdmin;
  final String? completedAt;
  final String? closedAt;

  // Relasi (eager loaded dari API)
  final Customer? customer;
  final Status? status;
  final AssignedUser? technician;

  const Assignment({
    required this.id,
    this.adminId,
    this.technicianId,
    this.customerId,
    this.statusId,
    this.descriptionByAdmin,
    this.latCheckIn,
    this.lngCheckIn,
    this.checkInPhotoPath,
    this.checkOutPhotoPath,
    this.latCheckOut,
    this.lngCheckOut,
    this.descriptionByTechnician,
    this.rating,
    this.reviewByAdmin,
    this.completedAt,
    this.closedAt,
    this.customer,
    this.status,
    this.technician,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);

  /// Nama status (lowercase) untuk filter stat card
  String get statusName => status?.name.toLowerCase() ?? '';
}
