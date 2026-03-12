import 'package:equatable/equatable.dart';
import '../model/login_model.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum user melakukan aksi apapun
class LoginInitial extends LoginState {
  final bool isPasswordVisible;
  const LoginInitial({this.isPasswordVisible = false});

  @override
  List<Object?> get props => [isPasswordVisible];
}

/// State saat request login sedang berlangsung
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// State saat login berhasil
class LoginSuccess extends LoginState {
  final UserModel user;
  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State saat login gagal
class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
