import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
// import 'package:guideme/controllers/home_controller.dart';
import 'package:guideme/views/auth/register_screen.dart'; // Import RegisterScreen
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/core/services/firebase_auth_service.dart'; // Import FirebaseAuthService
import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/core/constants/constants.dart'; // Import Constants

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService(); // Inisialisasi FirebaseAuthService
  // final HomeController _homeController = HomeController();
  final UserController _userController = UserController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // Periksa status login saat halaman dimulai
  }

  Future<void> _checkIfLoggedIn() async {
    bool isLoggedIn = await _authService.isLoggedIn(); // Metode untuk memeriksa status login
    if (isLoggedIn) {
      // Jika sudah login, arahkan langsung ke HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _loginUser(BuildContext context) async {
    // Cek apakah email kosong
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email cannot be empty")),
      );
      return;
    }

    // // Cek apakah email terdaftar
    // bool isEmailRegistered = await _userController.isEmailInUse(_emailController.text);
    // if (!isEmailRegistered) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Email is not registered")),
    //   );
    //   return;
    // }

    // Cek apakah password kosong
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password cannot be empty")),
      );
      return;
    }

    // Cek login menggunakan email dan password
    try {
      final user = await _authService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Berhasil login, arahkan ke halaman sesuai status pengguna
        _userController.loginUser(context, _emailController.text, _passwordController.text);
      } else {
        // Jika login gagal (misalnya password salah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect password")),
        );
      }
    } catch (e) {
      // Tangani kesalahan lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TitlePage(
                title: 'Login',
                subtitle: 'Log in to start planning your trip.',
                borderColor: Colors.blue,
              ),
              SizedBox(height: 40),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 20),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
              ),
              SizedBox(height: 40),
              LargeButton(
                label: 'Login',
                onPressed: () => _loginUser(context),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.smallStyle,
                  children: [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: "Register here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            SlideAnimation(
                              page: RegisterScreen(),
                              direction: AxisDirection.left,
                            ),
                          );
                        },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
