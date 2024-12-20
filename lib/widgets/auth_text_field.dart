import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller; // Menambahkan controller

  const AuthTextField({
    super.key,
    required this.label,
    required this.obscureText,
    required this.controller, // Controller ditambahkan di konstruktor
  });

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscureText;

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller, // Menambahkan controller
      obscureText: _isObscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textColor, // Sesuaikan dengan warna label
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
        contentPadding: const EdgeInsets.only(bottom: 10),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Border default
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primaryColor, // Border berubah warna saat fokus
          ),
        ),
        // Menambahkan icon hanya ketika obscureText true
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscureText ? AppIcons.eyeOpen : AppIcons.eyeClose,
                  color: AppColors.primaryColor, // Warna ikon
                ),
                onPressed: _togglePasswordVisibility, // Toggle password visibility
              )
            : null, // Tidak menampilkan ikon jika obscureText false
      ),
    );
  }
}
