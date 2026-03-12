import 'package:dio/dio.dart';
import '../../../core/base_model/base_model.dart';
import '../model/login_model.dart';

class LoginService {
  final Dio _dio;

  LoginService(this._dio);

  Future<LoginResponse> login({required String email, required String password}) async {
    final request = LoginRequest(email: email, password: password).toJson();
    final response = await _dio.post('/login', data: request);

    if (response.statusCode == 200) {
      final result = BaseModel.fromJson(
        response.data as Map<String, dynamic>,
        LoginResponse.fromJson,
      );
      if (result.data == null) throw Exception('Data login kosong');
      return result.data!;
    } else {
      throw Exception('Failed to login');
    }
  }
}

