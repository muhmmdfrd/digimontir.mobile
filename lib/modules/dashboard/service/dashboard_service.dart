import 'package:dio/dio.dart';
import '../model/dashboard_statistic.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<DashboardStatistic> getStatistic() async {
    final response = await _dio.get('/dashboard/statistic');
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return DashboardStatistic.fromJson(data);
    }
    throw Exception('Gagal memuat statistik dashboard');
  }
}
