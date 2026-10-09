import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../core/utils/custom_text_scaler.dart';
import '../core/utils/text_scale_utils.dart';
import '../core/services/deep_link_service.dart';
import '../core/services/display_density_service.dart';
import '../core/services/theme_mode_service.dart';
import '../core/services/remote_config_service.dart';
import '../features/home/presentation/pages/force_update_page.dart';
import '../features/home/presentation/pages/maintenance_page.dart';
import '../features/auth/application/auth_service.dart';
import '../features/chat/application/chat_service.dart';
import '../features/customer/application/customer_service.dart';
import '../features/wallet/application/wallet_service.dart';
import '../features/mitra/application/mitra_service.dart';
import 'di.dart';
import 'router.dart';

class TravelindoApp extends StatefulWidget {
  const TravelindoApp({super.key});

  @override
  State<TravelindoApp> createState() => _TravelindoAppState();
}

class _TravelindoAppState extends State<TravelindoApp> with WidgetsBindingObserver {
  late final AuthService _authService;
  bool _sessionReady = false;
  String? _maintenanceMessage;
  bool _forceUpdateRequired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authService = getIt<AuthService>();
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final user = _authService.user;
    if (user?.role == 'CUSTOMER' && getIt.isRegistered<CustomerService>()) {
      getIt<CustomerService>().loadMyBookings();
    }
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      getIt<DisplayDensityService>().load(),
      getIt<ThemeModeService>().load(),
    ]);
    await _authService.initBiometrics();
    await _authService.restoreSessionIfNeeded();
    if (mounted) setState(() => _sessionReady = true);
    final router = AppRouter.router(_authService);
    await DeepLinkService(router).initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppStatus();
    });
  }

  Future<void> _checkAppStatus() async {
    final remoteConfig = getIt<RemoteConfigService>();
    
    // 1. Check Maintenance Mode
    if (remoteConfig.isMaintenanceMode) {
      if (mounted) setState(() => _maintenanceMessage = remoteConfig.maintenanceMessage);
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final minVersion = remoteConfig.minVersion;

    if (remoteConfig.forceUpdate && _isVersionLower(currentVersion, minVersion)) {
      if (mounted) setState(() => _forceUpdateRequired = true);
    }
  }

  bool _isVersionLower(String current, String min) {
    try {
      final v1 = current.split('.').map(int.parse).toList();
      final v2 = min.split('.').map(int.parse).toList();
      for (var i = 0; i < v1.length && i < v2.length; i++) {
        if (v1[i] < v2[i]) return true;
        if (v1[i] > v2[i]) return false;
      }
      return v1.length < v2.length;
    } catch (_) {
      return current.compareTo(min) < 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_maintenanceMessage != null) {
      return MaterialApp(
        home: MaintenancePage(message: _maintenanceMessage!),
      );
    }

    if (_forceUpdateRequired) {
      return const MaterialApp(home: ForceUpdatePage());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: getIt<DisplayDensityService>()),
        ChangeNotifierProvider.value(value: getIt<ThemeModeService>()),
        ChangeNotifierProvider(create: (_) => getIt<MitraService>()),
        ChangeNotifierProvider(create: (_) => getIt<CustomerService>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatService>()),
        ChangeNotifierProvider(create: (_) => getIt<WalletService>()),
      ],
      child: Builder(
        builder: (context) {
          final density = context.watch<DisplayDensityService>();
          final themeMode = context.watch<ThemeModeService>().themeMode;
          final mediaQueryData = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: ClampedTextScaler(
                CustomTextScaler(mediaQueryData.textScaler, density.textScaleFactor),
                maxScaleFactor: 1.35,
              ),
            ),
            child: MaterialApp.router(
              title: 'Travelindo',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: AppRouter.router(_authService),
            ),
          );
        },
      ),
    );
  }
}

