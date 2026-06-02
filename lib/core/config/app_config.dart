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

  // Radius lokasi kerja untuk proses check-in/check-out dalam meter
  static const double assignmentCheckRadiusMeters = 50;

  // Batas upload foto mengikuti validasi Laravel: image|max:5120 (5 MB)
  static const int assignmentPhotoMaxUploadBytes = 5 * 1024 * 1024;
  static const double assignmentPhotoMaxDimension = 1280;
  static const int assignmentPhotoQuality = 45;
}
