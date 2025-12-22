import 'package:flutter/material.dart';
import '../../../core/widgets/profile_image_picker.dart';
import 'settings_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // final _fileService = FileStorageService(); // Removed
  String? _profileImagePath;
  
  // Mock User Data
  String _name = "Human User";
  String _email = "human@example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ProfileImagePicker(
                initialImagePath: _profileImagePath,
                onImageSelected: (path) {
                  setState(() {
                    _profileImagePath = path;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                _name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 48),
              _buildMenuItem(
                icon: Icons.pets,
                title: 'My Pets',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const SettingsScreen())
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                color: Colors.red,
                onTap: () {
                  // TODO: Implement logout
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.deepPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? Colors.deepPurple),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
