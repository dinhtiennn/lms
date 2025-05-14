import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';

import 'src/configs/configs.dart';
import 'src/presentation/presentation.dart';
import 'src/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp();
  await AppPrefs.initListener();
  await dotenv.load(fileName: ".env");
  await notificationInitialed();
  runApp(const OverlaySupport(child: RestartWidget(child: App())));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcherWidget(initialThemeData: normalTheme(context), child: const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Logger logger = Logger();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppDeviceInfo.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.i("ChangeAppLifecycleState: $state");
    StompService.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeSwitcher.of(context).themeData,
      navigatorObservers: <NavigatorObserver>[MyApp.observer],
      locale: AppPrefs.appLanguage ?? const Locale('vi', 'VN'),
      translationsKeys: AppTranslation.translations,
      fallbackLocale: const Locale('vi', 'VN'),
      home: const SplashScreen(),
      onGenerateRoute: Routers.generateRoute,
    );
  }
}
