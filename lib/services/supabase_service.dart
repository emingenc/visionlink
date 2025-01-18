import 'package:flutter/foundation.dart';
import 'package:visionlink/services/bluetooth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:visionlink/models/g1/notification.dart';
import 'package:visionlink/models/g1/note.dart';
import 'package:visionlink/models/g1/dashboard.dart';
import 'dart:async';
import 'package:visionlink/services/background_service.dart';

Uint8List decodeBase64(String base64Str) {
  try {
    return base64.decode(base64Str);
  } catch (e) {
    debugPrint('Base64 decoding failed: $e');
    return Uint8List(0);
  }
}

class SupabaseService {
  static final SupabaseService singleton = SupabaseService._internal();
  factory SupabaseService() => singleton;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _commandController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get commandStream => _commandController.stream;
  late String deviceId;
  late String userId;

  // Private channel variable
  late RealtimeChannel _channel;

  // Public getter for the channel
  RealtimeChannel get channel => _channel;

  Future<void> initialize() async {
    userId = await _getCurrentUserId();
    deviceId = 'g1';
    _channel = client.channel('public:device_commands');
    await subscribeToActions();
    await initializeService();
  }

  Future<String> _getCurrentUserId() async {
    final user = client.auth.currentUser;
    if (user != null) {
      return user.id;
    } else {
      throw Exception("No authenticated user found");
    }
  }

  Future<void> subscribeToActions() async {
    _subscription?.cancel();

    debugPrint('Subscribing to device commands for device: $deviceId');

    _channel
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
            _commandController.add(record);

            final commandType = record['command_type'] as String?;
            final params = record['params'] as Map<String, dynamic>? ?? {};

            try {
              switch (commandType) {
                case 'SEND_TEXT':
                  final text = params['text'] ?? 'Hello';
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
  }

  void dispose() {
    _subscription?.cancel();
    _commandController.close();
  }

  Future<void> insertTranscription(String text) async {
    try {
      if (userId.isEmpty) {
        userId = await _getCurrentUserId();
      }

      await client.from('transcriptions').insert({
        'user_id': userId,
        'device_id': deviceId,
        'text': text,
      });
    } catch (e) {
      debugPrint('Error inserting transcription: $e');
      rethrow;
    }
  }
}
