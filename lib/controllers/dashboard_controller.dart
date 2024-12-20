import 'package:flutter/material.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/admin/event_management/event_screen.dart';
import 'package:guideme/views/admin/user_management/user_screen.dart';

class DashboardController {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  // Fungsi untuk memperbarui indeks tab yang dipilih
  void onItemTapped(int index) {
    _selectedIndex = index;
  }

  // Fungsi untuk mendapatkan halaman yang dipilih
  Widget getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(); // Halaman pengguna
      case 1:
        return EventScreen(); // Halaman manajemen acara
      default:
        return UserScreen();
    }
  }
}
