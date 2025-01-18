import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visionlink/services/bluetooth_manager.dart';
import 'package:visionlink/services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visionlink/utils/ui_perfs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'package:visionlink/screens/auth/sign_in.dart';
import 'package:visionlink/screens/auth/update_password.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

 

  // Now proceed with your normal initialization:
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    runApp(const MaterialApp(
      home: SignUp(),
      debugShowCheckedModeBanner: false,
    ));
    return;
  }


  
  
  await _initHive();
  await UiPerfs.singleton.load();
  await BluetoothManager.singleton.initialize();
  BluetoothManager.singleton.attemptReconnectFromStorage();

  final supabaseService = SupabaseService();
  await supabaseService.initialize();


  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Glasses Core OS',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUp(),
        '/update_password': (context) => const UpdatePassword(),
        '/home': (context) => const HomePage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Not Found',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _initHive() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.initFlutter();
  
  // Open the 'NotificationApps' box
  await Hive.openBox('NotificationApps');
}

const notificationChannelId = 'my_foreground';
const notificationId = 888;


void _handleDeleteAction(String actionId) {
  // Delete action handling
}

void notificationTapBackground(NotificationResponse response) {
  // Handle background notification tap
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
