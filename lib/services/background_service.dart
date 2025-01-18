import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:visionlink/services/supabase_service.dart';
import 'package:visionlink/services/bluetooth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visionlink/models/g1/notification.dart';
import 'package:visionlink/models/g1/note.dart';
import 'package:visionlink/models/g1/dashboard.dart';

final supabase = Supabase.instance.client;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await BluetoothManager.singleton.initialize();
  BluetoothManager.singleton.attemptReconnectFromStorage();

  final session = SupabaseService.singleton.client.auth.currentSession;
  if (session != null) {
    final channel = Supabase.instance.client.channel('public:device_commands');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'device_commands',
          callback: (payload) {
            debugPrint('Change received: ${payload.toString()}');
            final record = payload.newRecord;
            if (record == null || record.isEmpty) {
              debugPrint('Empty record received');
              return;
            }

            final timestamp = record['updated_at'] as String?;

            final commandType = record['command_type'] as String?;
            final params = record['params'] as Map<String, dynamic>? ?? {};

            try {
              switch (commandType) {
                case 'SEND_TEXT':
                  final text = params['text'] ?? 'Hello';
                  debugPrint('Sending text: $text');
                  BluetoothManager.singleton.sendText(text);
                  break;
                case 'SEND_NOTIFICATION':
                  final msgId = params['msgId'] ?? 0;
                  final message = params['message'] ?? 'Notification text';
                  final title = params['title'] ?? 'Notification title';
                  final subtitle =
                      params['subtitle'] ?? 'Notification subtitle';
                  final appIdentifier =
                      params['appIdentifier'] ?? 'org.telegram.messenger';
                  final displayName = params['displayName'] ?? 'DEV';
                  BluetoothManager.singleton.sendNotification(
                    NCSNotification(
                      msgId: msgId,
                      appIdentifier: appIdentifier,
                      title: title,
                      subtitle: subtitle,
                      message: message,
                      displayName: displayName,
                    ),
                  );
                  break;

                case 'SEND_IMAGE':
                  final imageStr = params['image'] as String? ?? '';
                  if (imageStr.isNotEmpty) {
                    try {
                      final image = decodeBase64(imageStr);
                      BluetoothManager.singleton.sendBitmap(image);
                    } catch (e) {
                      debugPrint('Error decoding image: $e');
                    }
                  } else {
                    debugPrint('No image data provided');
                  }
                  break;

                case 'SEND_NOTE':
                  final noteNumber = params['noteNumber'] ?? 1;
                  final name = params['name'] ?? 'Note 1';
                  final text = params['text'] ?? 'This is a note';
                  final note = Note(
                    noteNumber: noteNumber,
                    name: name,
                    text: text,
                  );
                  BluetoothManager.singleton.sendNote(note);
                  BluetoothManager.singleton
                      .setDashboardLayout(DashboardLayout.DASHBOARD_DUAL);
                  break;

                case 'SEND_COMMAND':
                  final commandStr = params['command'] as String? ?? '';
                  if (commandStr.isNotEmpty) {
                    try {
                      final command = decodeBase64(commandStr);
                      BluetoothManager.singleton.sendCommandToGlasses(command);
                    } catch (e) {
                      debugPrint('Error decoding command: $e');
                    }
                  } else {
                    debugPrint('No command data provided');
                  }
                  break;

                default:
                  debugPrint('Unknown command_type: $commandType');
              }
            } catch (e) {
              debugPrint('Error processing command: $e');
            }
          },
        )
        .subscribe();
  } else {
    debugPrint('[onStart] No session available');
  }
}
