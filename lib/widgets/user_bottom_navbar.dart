// // file: lib/widgets/bottom_navbar.dart

// import 'package:flutter/material.dart';
// import 'package:guideme/core/constants/constants.dart'; // Pastikan import untuk AppIcons

// class BottomNavbar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   BottomNavbar({required this.selectedIndex, required this.onItemTapped});

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: selectedIndex,
//       onTap: onItemTapped,
//       showSelectedLabels: false, // Menyembunyikan label pada tab yang dipilih
//       showUnselectedLabels: false, // Menyembunyikan label pada tab yang tidak dipilih
//       items: <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(AppIcons.home), // Memanggil ikon home dari AppIcons
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(AppIcons.login), // Gunakan ikon login dari AppIcons
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(AppIcons.register), // Gunakan ikon register dari AppIcons
//           label: '',
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/views/auth/register_screen.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // Pastikan untuk mengimpor pustaka Phosphor Icons

class serBottomNavbar extends StatelessWidget {
  final int selectedIndex;

  const serBottomNavbar({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = HomeScreen(); // Halaman Dashboard
        break;
      case 1:
        page = LoginScreen(); // Halaman Manajemen Pengguna
        break;
      case 2:
        page = RegisterScreen(); // Halaman Manajemen Acara
        break;
      default:
        page = HomeScreen();
    }

    // Menggunakan PageRouteBuilder dengan fade transition dan durasi yang lebih lambat
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: AppColors.backgroundColor,
      unselectedItemColor: AppColors.secondaryColor,
      selectedItemColor: AppColors.primaryColor,
      items: [
        BottomNavigationBarItem(
          icon: _buildIconWithBorder(AppIcons.home, 0),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithBorder(AppIcons.login, 1),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithBorder(AppIcons.register, 2),
          label: '',
        ),
      ],
    );
  }

  // Fungsi untuk menambahkan border atas pada item yang aktif
  Widget _buildIconWithBorder(PhosphorIconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: selectedIndex == index
                ? AppColors.primaryColor // Warna border atas saat item aktif
                : Colors.transparent, // Transparan jika tidak aktif
            width: 3.0, // Ketebalan border
          ),
        ),
      ),
      child: Icon(icon),
    );
  }
}
