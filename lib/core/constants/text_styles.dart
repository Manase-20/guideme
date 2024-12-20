import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textColor,
  );
  static const TextStyle subtitleBold = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16.0,
    color: AppColors.textColor,
  );
  static const TextStyle bodyBold = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);

  static const TextStyle mediumStyle = TextStyle(
    fontSize: 14.0,
    color: AppColors.textColor,
  );
  static const TextStyle mediumBold = TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);

  static const TextStyle smallStyle = TextStyle(
    fontSize: 12.0,
    color: AppColors.textColor,
  );
  static const TextStyle tinyStyle = TextStyle(
    fontSize: 10.0,
    color: AppColors.textColor,
  );

  static const TextStyle largeButtonStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
