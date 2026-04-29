class AppConfig {
  AppConfig._();

  // Base URL API — ubah sesuai environment
  static const String baseUrl = 'https://digimontir.ngeproject.my.id/api';

  // Timeout dalam milidetik
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Flag debug — set false saat production
  static const bool isDebug = true;

  // Nama app
  static const String appName = 'Digimontir';
}
