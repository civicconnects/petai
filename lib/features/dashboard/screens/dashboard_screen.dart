import 'package:flutter/material.dart';
import '../../chat/screens/chat_screen.dart';
import '../../dashboard/screens/health_dashboard_screen.dart';
import 'pets_tab.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Defined inside build to access _onItemTapped wrapper if needed, 
    // or just passed directly. 
    final List<Widget> widgetOptions = <Widget>[
      HealthDashboardScreen(onNavigateToTab: _onItemTapped),
      const ChatScreen(),
      const PetsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPath AI'),
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar( // Using NavigationBar (Material 3) for better 4-item layout
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
           NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Ask AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
