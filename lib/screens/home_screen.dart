import 'package:visionlink/screens/settings_screen.dart';
import 'package:visionlink/widgets/glass_status.dart';
import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';
import '../services/bluetooth_reciever.dart';
import '../services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothManager bluetoothManager = BluetoothManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Link'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) => setState(() {}));
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFECE9E6),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GlassStatus(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Incoming Commands',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: SupabaseService.singleton.commandStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No incoming commands yet.'));
                    }
                    final command = snapshot.data!;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text('Command: ${command['command_type']}'),
                        subtitle: Text('Params: ${command['params'].toString()} \n\n Sender: ${command['sender']}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Latest Transcription',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<String>(
                  stream: BluetoothReciever.transcriptionStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No transcriptions yet.'));
                    }
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(snapshot.data ?? ''),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
