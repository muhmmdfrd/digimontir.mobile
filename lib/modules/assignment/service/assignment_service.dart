import 'package:dio/dio.dart';
import '../model/assignment_model.dart';

class AssignmentService {
  final Dio _dio;

  AssignmentService(this._dio);

  Future<List<Assignment>> getAssignments({String? tab, int? statusId}) async {
    final queryParameters = <String, dynamic>{};
    if (tab != null) queryParameters['tab'] = tab;
    if (statusId != null) queryParameters['status_id'] = statusId;

    final response = await _dio.get('/assignments', queryParameters: queryParameters);
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      // Handle wrapper {data: [...], message: "..."} dari Laravel
      final rawList = body['data'] is List
          ? body['data'] as List
          : (body['assignments'] as List? ?? []);
      return rawList
          .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat data assignment');
  }

  Future<Assignment> getAssignment(int id) async {
    final response = await _dio.get('/assignments/$id');
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return Assignment.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat detail assignment');
  }

  Future<Assignment> checkIn(int id, double lat, double lng, String photoPath) async {
    final formData = FormData.fromMap({
      'lat_check_in': lat,
      'lng_check_in': lng,
      'check_in_photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _dio.post('/assignments/$id/check-in', data: formData);
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return Assignment.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Gagal check-in');
  }

  Future<Assignment> checkOut(int id, double lat, double lng, String description, String photoPath) async {
    final formData = FormData.fromMap({
      'lat_check_out': lat,
      'lng_check_out': lng,
      'description_by_technician': description,
      'check_out_photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _dio.post('/assignments/$id/check-out', data: formData);
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return Assignment.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Gagal check-out');
  }
}

