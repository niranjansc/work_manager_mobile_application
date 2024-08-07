import 'package:flutter/material.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class PasswordEdtWidget extends StatefulWidget {
  const PasswordEdtWidget(
      {super.key,
      required this.height,
      required this.width,
      required this.hinttext,
      required this.passwordController});
  final double height;
  final double width;
  final String hinttext;
  final TextEditingController passwordController;
  @override
  State<PasswordEdtWidget> createState() => _PasswordEdtWidgetState();
}

class _PasswordEdtWidgetState extends State<PasswordEdtWidget> {
  bool _showPassword = true;
  TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.passwordController == null)
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
        keyboardType: TextInputType.name,
        controller: _emailController,
        style: ralewayStyle.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.blueDarkColor,
            fontSize: 12.0),
        obscureText: _showPassword,
        decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: IconButton(
                onPressed: () {
                  if (_showPassword == true) {
                    setState(() {
                      _showPassword = false;
                    });
                  } else {
                    setState(() {
                      _showPassword = true;
                    });
                  }
                },
                icon: _showPassword
                    ? const Icon(Icons.remove_red_eye)
                    : const Icon(Icons.no_encryption_gmailerrorred_outlined)),
            prefixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.security),
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
