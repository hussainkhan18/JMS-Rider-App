import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jms/routes/app_routes.dart';
import 'package:jms/services/api_service.dart';
import 'package:jms/view_models/auth/user_view_model.dart';
import 'package:jms/view_models/cart_view_model.dart';
import 'package:jms/view_models/help_viewmodel.dart';
import 'package:jms/view_models/my_order_view_model.dart';
import 'package:jms/view_models/riderlocation_view_model.dart';
import 'package:jms/view_models/staff_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Save FCM token to SharedPreferences
  await _saveFcmToken();

  // Disable rotation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final apiService = ApiService(baseUrl: 'https://jalmanagementsystem.com');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyOrderViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => StaffViewModel()),
        ChangeNotifierProvider(create: (_) => RiderLocationProvider()),
        ChangeNotifierProvider(create: (_) => HelpViewModel(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

// Function to get and save FCM token
Future<void> _saveFcmToken() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (for iOS, safe for Android too)
    await messaging.requestPermission();

    // Get token
    String? token = await messaging.getToken();
    debugPrint("🔑 FCM Token: $token");

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcm_token", token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 FCM Token refreshed: $newToken");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcm_token", newToken);
    });
  } catch (e) {
    debugPrint("⚠️ FCM Service not available: $e");
    // App continues without FCM if service unavailable
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splashScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
