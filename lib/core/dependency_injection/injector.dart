import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gear_up_bloc/core/database/hive_storage_service.dart';
import 'package:gear_up_bloc/core/database/secure_storage_service.dart';
import 'package:gear_up_bloc/core/network/connection/network_info.dart';
import 'package:gear_up_bloc/core/network/dio_network_service.dart';
import 'package:gear_up_bloc/core/network/network_service.dart';
import 'package:gear_up_bloc/features/login/data/data_source/login_remote_data_source.dart';
import 'package:gear_up_bloc/features/login/data/repositories/login_repository_impl.dart';
import 'package:gear_up_bloc/features/login/domain/repositories/login_repository.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:get_it/get_it.dart';


final injector = GetIt.instance;

Future<void> init() async {
  /// --- Core Services (Layer 0) ---
  final secureStorage = SecureStorageService();
  injector.registerLazySingleton<SecureStorageService>(() => secureStorage);

  final hiveService = HiveService(secureStorage);
  // await hiveService.init();
  injector.registerLazySingleton<HiveService>(() => hiveService);

  injector.registerLazySingleton<NetworkService>(DioNetworkService.new);
  injector.registerLazySingleton<Connectivity>(Connectivity.new);
  injector.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(injector()),
  );

  /// --- Feature 1: Auth / Login ---
  // Data Source
  injector.registerLazySingleton<LoginRemoteDataSource>(
        () => LoginRemoteDataSourceImpl(injector()),
  );
  // Repository
  injector.registerLazySingleton<LoginRepository>(
        () => LoginRepositoryImpl(injector()),
  );
  // Use Case
  injector.registerLazySingleton<LoginUseCases>(
        () => LoginUseCases(injector()),
  );
}