import 'package:flutter/material.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({super.key, required this.title});
  final String title;
  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 18.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), color: Colors.deepOrange),
      child: Text(
        widget.title,
        style: ralewayStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.whiteColor,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
