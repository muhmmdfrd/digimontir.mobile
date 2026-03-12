import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../service/login_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService _loginService;

  LoginBloc({required LoginService loginService}) : _loginService = loginService, super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // Validasi sederhana
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const LoginFailure(message: 'Email dan password tidak boleh kosong'));
      return;
    }

    emit(const LoginLoading());

    try {
      final response = await _loginService.login(email: event.email, password: event.password);

      // Simpan token & seluruh UserModel sebagai JSON ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.token);
      await prefs.setString('user_data', jsonEncode(response.user.toJson()));

      emit(LoginSuccess(user: response.user));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'Terjadi kesalahan. Silakan coba lagi.';
      emit(LoginFailure(message: msg));
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  void _onPasswordVisibilityToggled(LoginPasswordVisibilityToggled event, Emitter<LoginState> emit) {
    final current = state;
    final isVisible = current is LoginInitial ? current.isPasswordVisible : false;
    emit(LoginInitial(isPasswordVisible: !isVisible));
  }
}
