import 'package:flutter/material.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';


class ComnboBoxWidget extends StatefulWidget {
  const ComnboBoxWidget({super.key, required this.height, required this.width, required this.hinttext, required this.textController, required this.icon});
final double height;
  final double width;
  final String hinttext;
  final TextEditingController textController;
  final IconData icon;
  @override
  State<ComnboBoxWidget> createState() => _ComnboBoxWidgetState();
}

class _ComnboBoxWidgetState extends State<ComnboBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  
  }
}