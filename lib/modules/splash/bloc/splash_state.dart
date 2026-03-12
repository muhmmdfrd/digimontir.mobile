import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// State awal saat splash screen dimuat
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State ketika user sudah login sebelumnya → navigasi ke home
class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

/// State ketika user belum login → navigasi ke login
class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
