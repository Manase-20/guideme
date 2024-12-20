import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/services/firebase_options.dart'; // File auto-generated oleh Firebase
import 'package:guideme/views/admin/dashboard_screen.dart';
// import 'firebase_options.dart'; // File auto-generated oleh Firebase

// screen
// import 'package:guideme/views/auth/login_screen.dart' as auth;
// import 'package:guideme/views/auth/register_screen.dart' as auth;
import 'package:guideme/views/user/home_screen.dart';
// import 'package:guideme/views/admin/user_management/user_screen.dart' as admin;

// konstanta
import 'package:guideme/core/constants/constants.dart';
import 'package:provider/provider.dart';
// import 'package:guideme/views/user/home_screen.dart';

// example
// import 'package:firebase_functions/firebase_functions.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:guideme/views/user/profile/profile.dart';
// import 'package:guideme/core/services/midtrans_service.dart';
// import 'package:midtrans_flutter/midtrans_flutter.dart';

//supabase
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // supabase
  await Supabase.initialize(
    url: 'https://errgdpvuqptgmkobutnt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVycmdkcHZ1cXB0Z21rb2J1dG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzOTg2MTAsImV4cCI6MjA0ODk3NDYxMH0.bOPICi0eFnqBFiNyufFgrVtXvradIylCNMenDFE0XHk',
  );
  // await dotenv.load();
  // print("Dotenv loaded");
  // runApp(MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di aplikasi
      title: AppStrings.appTitle,
      theme: ThemeData(
        // Tentukan warna utama dan latar belakang aplikasi
        primaryColor: Colors.white, // Menentukan warna utama aplikasi.
        scaffoldBackgroundColor: AppColors.backgroundColor, // Mengatur warna latar belakang aplikasi

        // Menentukan font utama untuk aplikasi
        fontFamily: 'Inter', // Menetapkan Inter sebagai font default

        // Tentukan tema teks untuk berbagai ukuran dan jenis teks
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal),
          titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          // Anda dapat menyesuaikan lebih lanjut sesuai kebutuhan aplikasi
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // final FirebaseAuthService _auth = FirebaseAuthService(); // Service autentikasi dan Firestore
  bool _showButton = false;
  bool _isLoading = true; // Untuk kontrol loading

  @override
  void initState() {
    super.initState();
    // Timer untuk menampilkan tombol setelah 3 detik
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        // _checkLogin();
        _showButton = true;
        _isLoading = false; // Hentikan loading setelah 3 detik
      });
    });
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.fetchCurrentUser(); // Ambil data pengguna
    if (authProvider.uid != null) {
      // Cek role pengguna dan navigasikan
      if (authProvider.role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (authProvider.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      // Jika belum login, kembali ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: 1.5,
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/icons/launcher_icon.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(color: Colors.white), // Menampilkan CircularProgressIndicator hanya saat loading
            SizedBox(height: 40),
            if (_showButton) // Menampilkan tombol setelah loading selesai
              ElevatedButton(
                onPressed: _checkLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


//   Future<void> _checkLogin() async {
//     // Mengecek status login
//     bool isLoggedIn = await _auth.isLoggedIn();
//     if (isLoggedIn) {
//       // Mendapatkan informasi pengguna saat ini
//       var currentUser = await _auth.getCurrentUser();
//       if (currentUser != null) {
//         // Arahkan berdasarkan role pengguna
//         String role = currentUser['role']!;
//         if (role == 'user') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()), // Halaman Home untuk pengguna
//           );
//         } else if (role == 'admin') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => DashboardScreen()), // Halaman Dashboard untuk admin
//           );
//         } else {
//           // Jika role tidak dikenal, kembali ke LoginScreen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         }
//       } else {
//         // Jika data pengguna tidak ditemukan, kembali ke HomeScreen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       }
//     } else {
//       // Jika belum login, navigasi ke LoginScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }