import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("App Version"),
            trailing: const Text("2.1.0"),
          ),
        ],
      ),
    );
  }
}
