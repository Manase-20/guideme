import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/user/home_screen.dart';

class CloseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CloseAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          AppIcons.close,
          color: AppColors.textColor,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // Menghapus semua rute sebelumnya
            );
          }
        },
      ),
      title: null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom; // Parameter opsional untuk TabBar

  const BackAppBar({
    super.key,
    required this.title,
    this.bottom, // Nilai default adalah null
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Ganti dengan AppColors.backgroundColor jika digunakan
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back, // Ganti dengan AppIcons.back jika digunakan
          color: Colors.black, // Ganti dengan AppColors.textColor jika digunakan
        ),
        onPressed: () {
          Navigator.pop(context); // Menutup halaman dan kembali ke halaman sebelumnya
        },
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Menutup halaman dan kembali ke halaman sebelumnya
        },
        child: Text(
          'Back',
          style: AppTextStyles.headingStyle.copyWith(fontWeight: FontWeight.bold), // Ganti dengan AppTextStyles.bodyStyle jika digunakan
        ),
      ),
      bottom: bottom, // Menampilkan TabBar jika diberikan
    );
  }

  @override
  Size get preferredSize {
    // Kembalikan ukuran tinggi AppBar + tinggi bottom (jika ada)
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
    );
  }
}
