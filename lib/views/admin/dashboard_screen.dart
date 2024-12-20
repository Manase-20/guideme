import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/dummy/create_map.dart';
import 'package:guideme/dummy/dashboard_screen.dart';
import 'package:guideme/dummy/map_screen.dart';
import 'package:guideme/views/admin/destination_management/destination_screen.dart';
import 'package:guideme/views/admin/event_management/event_screen.dart';
import 'package:guideme/views/admin/gallery_management/gallery_screen.dart';
import 'package:guideme/views/admin/ticket_management/create_ticket_screen.dart';
import 'package:guideme/views/admin/ticket_management/ticket_management_screen.dart';
import 'package:guideme/views/admin/user_management/user_screen.dart';
import 'package:guideme/views/admin/category_management/category_screen.dart';
import 'package:guideme/views/admin/gallery_management/create_gallery_screen.dart';
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/controllers/dashboard_controller.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/views/user/ticket/ticket_screen.dart';
import 'package:guideme/widgets/custom_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserController _userController = UserController();

  bool _isLoggedIn = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    var currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      String role = currentUser['role']!;
      if (role != 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // Future<void> _handleLogout() async {
  //   await _userController.logout();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Logout successful")),
  //   );
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => LoginScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.primaryColor)),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Panggil handleLogout dari auth_utils.dart
              handleLogout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Manage Example',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExampleScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.person,
              title: 'Manage Users',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Manage Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.description,
              title: 'Manage Destinations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DestinationScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.category,
              title: 'Manage Categories',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.photo_album,
              title: 'Manage Gallery',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryManagementScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: AppIcons.ticket,
              title: 'Manage Ticket',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicketManagementScreen()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 0),
      backgroundColor: AppColors.backgroundColor,
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 8,
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
