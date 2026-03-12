import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Dipanggil saat splash screen pertama kali muncul
class SplashStarted extends SplashEvent {
  const SplashStarted();
}
