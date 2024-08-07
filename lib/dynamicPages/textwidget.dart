import 'package:flutter/material.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class TextWidget extends StatefulWidget {
  const TextWidget(
      {super.key,
      required this.title,
      required this.fontsize,
      required this.color});
  final String title;
  final double fontsize;
  final Color color;
  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.title,
        style: ralewayStyle.copyWith(
          fontSize: widget.fontsize,
          color: widget.color,
          fontWeight: FontWeight.bold,
        ));
  }
}
