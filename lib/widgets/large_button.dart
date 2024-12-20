import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';

class LargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const LargeButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor, // Mengatur warna background tombol
        foregroundColor: AppColors.secondaryTextColor, // Mengatur warna teks tombol
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0), // Padding untuk tombol lebih besar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Sudut tombol melengkung
        ),
        minimumSize: Size(double.infinity, 50), // Tombol memenuhi lebar layar dan tinggi tertentu
      ),
      child: Text(
        label,
        style: AppTextStyles.largeButtonStyle, // Ukuran teks pada tombol
      ),
    );
  }
}
