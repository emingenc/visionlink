import 'package:visionlink/screens/settings/debug_screen.dart';
import 'package:visionlink/screens/settings/notifications_screen.dart';
import 'package:visionlink/screens/settings/whisper_screen.dart';
import 'package:visionlink/widgets/about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:visionlink/services/bluetooth_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          
          
          ListTile(
            title: Row(
              children: [
                Icon(Icons.mic),
                SizedBox(width: 10),
                Text('Whisper'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WhisperSettingsPage()),
              );
            },
          ),
          
          ListTile(
            title: Row(
              children: [
                Icon(Icons.notifications),
                SizedBox(width: 10),
                Text('App Notifications'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.bug_report),
                SizedBox(width: 10),
                Text('Debug'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebugPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 10),
                Text('About'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () => showCustomAboutDialog(context),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await BluetoothManager.singleton.disconnectGlasses();
                Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
