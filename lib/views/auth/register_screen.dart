import 'package:flutter/material.dart';
import 'package:guideme/controllers/user_controller.dart'; // Import UserController
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/core/services/firebase_auth_service.dart'; // Jika ada widget yang digunakan seperti AuthTextField

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // final FirebaseAuthService _authService = FirebaseAuthService();
  final UserController _userController = UserController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _registerUser(BuildContext context) async {
    // Cek apakah username kosong
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username cannot be empty")),
      );
      return;
    }

    // // Cek apakah username sudah digunakan
    // bool isUsernameTaken = await _userController.isUsernameTaken(_usernameController.text);
    // if (isUsernameTaken) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Username is already taken")),
    //   );
    //   return;
    // }

    // Cek apakah email kosong
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email cannot be empty")),
      );
      return;
    }

    // // Cek apakah email sudah digunakan
    // bool emailInUse = await _userController.isEmailInUse(_emailController.text);
    // if (emailInUse) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Email is already in use")),
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

    // Cek apakah confirm password kosong
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please confirm your password")),
      );
      return;
    }

    // Cek apakah password dan confirm password sama
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Jika username dan email valid, lanjutkan registrasi
    String? validationMessage = await _userController.registerUser(
      context,
      _emailController.text,
      _passwordController.text,
      _usernameController.text,
    );

    // Jika ada pesan validasi, tampilkan Snackbar
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMessage)),
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
              TitlePage(title: "Register", subtitle: "Create a new account."),
              SizedBox(height: 40),
              AuthTextField(
                controller: _usernameController,
                label: 'Username',
                obscureText: false,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscureText: true,
              ),
              SizedBox(height: 40),
              LargeButton(
                label: 'Register',
                onPressed: () => _registerUser(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
