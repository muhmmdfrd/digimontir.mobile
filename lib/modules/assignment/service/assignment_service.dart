import 'package:dio/dio.dart';
import '../model/assignment_model.dart';

class AssignmentService {
  final Dio _dio;

  AssignmentService(this._dio);

  Future<List<Assignment>> getAssignments() async {
    final response = await _dio.get('/assignments');
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
}

