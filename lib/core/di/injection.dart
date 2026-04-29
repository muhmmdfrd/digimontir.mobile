import 'package:get_it/get_it.dart';
import '../../modules/login/service/login_service.dart';
import '../../modules/assignment/service/assignment_service.dart';
import '../../modules/dashboard/service/dashboard_service.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  sl.registerLazySingleton<LoginService>(
    () => LoginService(DioClient.instance),
  );
  sl.registerLazySingleton<AssignmentService>(
    () => AssignmentService(DioClient.instance),
  );
  sl.registerLazySingleton<DashboardService>(
    () => DashboardService(DioClient.instance),
  );
}

