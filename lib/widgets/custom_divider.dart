import 'package:flutter/material.dart';
import 'package:guideme/core/constants/colors.dart';

class greyDivider extends StatelessWidget {
  final double thickness;
  final Color color;

  const greyDivider({
    Key? key,
    this.thickness = 1.0,
    this.color = AppColors.tertiaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 4,
        ),
        Divider(
          thickness: thickness,
          color: color,
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}
