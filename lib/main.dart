import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'app/env.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/realtime_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/widgets/layout/adaptive_screen_util_init.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await EasyLocalization.ensureInitialized();
  await AppEnv.load();
  AppEnv.assertProductionSecurity();
  await configureDependencies();

  await getIt<RemoteConfigService>().init();
  if (!kIsWeb) {
    await PushNotificationService.instance.initialize();
  }
  getIt<RealTimeService>().init();
  
  runApp(
    AdaptiveScreenUtilInit(
      builder: (context, child) => EasyLocalization(
        supportedLocales: const [Locale('id'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('id'),
        child: child ?? const TravelindoApp(),
      ),
      child: const TravelindoApp(),
    ),
  );
}
