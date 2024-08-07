import 'package:flutter/material.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class EditTextWidget extends StatefulWidget {
  const EditTextWidget(
      {super.key,
      required this.height,
      required this.width,
      required this.hinttext,
      required this.textController,
      required this.icon});
  final double height;
  final double width;
  final String hinttext;
  final TextEditingController textController;
  final IconData icon;
  @override
  State<EditTextWidget> createState() => _EditTextWidgetState();
}

class _EditTextWidgetState extends State<EditTextWidget> {
  TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.textController == null)
      _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: AppColors.whiteColor,
      ),
      child: TextFormField(
        controller: _emailController,
        style: ralewayStyle.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.blueDarkColor,
            fontSize: 12.0),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: IconButton(
              onPressed: () {},
              icon: Icon(widget.icon),
            ),
            contentPadding: const EdgeInsets.only(top: 16.0),
            hintText: widget.hinttext,
            hintStyle: ralewayStyle.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.blueDarkColor.withOpacity(0.5),
                fontSize: 12.0)),
      ),
    );
  
  }
}
