import 'package:flutter/material.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:guideme/core/services/auth_provider.dart'; // Sesuaikan dengan path yang benar

// Fungsi untuk menangani logout
Future<void> handleLogout(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.logout();

  // Menampilkan SnackBar setelah logout berhasil
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Logout successful")),
  );

  // Navigasi ke halaman login setelah logout
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
}
