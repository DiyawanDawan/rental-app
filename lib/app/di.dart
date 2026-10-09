import 'package:get_it/get_it.dart';

import '../core/cache/reference_data_cache.dart';
import '../core/network/api_client.dart';
import '../core/services/display_density_service.dart';
import '../core/services/theme_mode_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/rental_location_share_service.dart';
import '../core/services/remote_config_service.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/application/auth_service.dart';
import '../features/auth/data/auth_remote_datasource.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/chat/application/chat_service.dart';
import '../features/chat/data/chat_remote_datasource.dart';
import '../features/chat/data/chat_repository.dart';
import '../features/customer/application/customer_service.dart';
import '../features/customer/data/customer_remote_datasource.dart';
import '../features/customer/data/customer_repository.dart';
import '../features/health/data/health_remote_datasource.dart';
import '../features/health/data/health_repository.dart';
import '../features/mitra/application/mitra_service.dart';
import '../features/mitra/data/mitra_remote_datasource.dart';
import '../features/mitra/data/mitra_repository.dart';
import '../features/wallet/application/wallet_service.dart';
import '../features/wallet/data/wallet_remote_datasource.dart';
import '../features/wallet/data/wallet_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<TokenStorage>()) {
    return;
  }

  getIt
    ..registerLazySingleton<TokenStorage>(TokenStorage.new)
    ..registerLazySingleton<RealTimeService>(
      () => RealTimeService(getIt<ApiClient>()),
    )
    ..registerLazySingleton<RemoteConfigService>(RemoteConfigService.new)
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(tokenStorage: getIt<TokenStorage>()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    )
    ..registerLazySingleton<AuthService>(
      () => AuthService(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<CustomerRepository>(
      () => CustomerRepository(getIt<CustomerRemoteDataSource>()),
    )
    ..registerLazySingleton<WalletRemoteDataSource>(
      () => WalletRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<WalletRepository>(
      () => WalletRepository(getIt<WalletRemoteDataSource>()),
    )
    ..registerLazySingleton<ReferenceDataCache>(
      () => ReferenceDataCache(getIt<WalletRepository>(), getIt<CustomerRepository>()),
    )
    ..registerLazySingleton<RentalLocationShareService>(
      () => RentalLocationShareService(getIt<CustomerRepository>()),
    )
    ..registerLazySingleton<CustomerService>(
      () => CustomerService(
        getIt<CustomerRepository>(),
        getIt<RealTimeService>(),
        getIt<ReferenceDataCache>(),
        getIt<RentalLocationShareService>(),
      ),
    )
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepository(getIt<ChatRemoteDataSource>()),
    )
    ..registerLazySingleton<ChatService>(
      () => ChatService(
        getIt<ChatRepository>(),
        getIt<AuthService>(),
        getIt<RealTimeService>(),
      ),
    )
    ..registerLazySingleton<WalletService>(
      () => WalletService(getIt<WalletRepository>(), getIt<ReferenceDataCache>()),
    )
    ..registerLazySingleton<HealthRemoteDataSource>(
      () => HealthRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<HealthRepository>(
      () => HealthRepository(getIt<HealthRemoteDataSource>()),
    )
    ..registerLazySingleton<MitraRemoteDataSource>(
      () => MitraRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<MitraRepository>(
      () => MitraRepository(
        remoteDataSource: getIt<MitraRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    )
    ..registerLazySingleton<DisplayDensityService>(DisplayDensityService.new)
    ..registerLazySingleton<ThemeModeService>(ThemeModeService.new)
    ..registerLazySingleton<MitraService>(
      () => MitraService(getIt<MitraRepository>(), getIt<RealTimeService>()),
    );
}
