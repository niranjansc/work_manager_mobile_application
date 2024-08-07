// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/SharedPreferencesUtils.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;
import 'package:work_manager/utils/responsive_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    //getDefaultValue();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SizedBox(
        width: width,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveWidget.isSmallScreen(context)
                ? const SizedBox()
                : Expanded(
                    child: Container(
                      color: AppColors.mainBlueColor,
                      height: height,
                      child: Center(
                        child: Text(
                          'Task Management App',
                          style: ralewayStyle.copyWith(
                              fontSize: 48.0,
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
            _FormUI(height: height, width: width),
          ],
        ),
      ),
    );
  }

  void getDefaultValue() async {
    glb.prefs = await SharedPreferences.getInstance();

    var userId = glb.prefs!.getString('userId');
    if (userId!.isEmpty == false) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, MultiProfileRoute);
    }
  }
}

class _FormUI extends StatefulWidget {
  const _FormUI({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  State<_FormUI> createState() => _FormUIState();
}

class _FormUIState extends State<_FormUI> {
  bool isLoading = false, _showPassword = true;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          color: AppColors.backColor,
          margin: EdgeInsets.symmetric(
              horizontal: ResponsiveWidget.isSmallScreen(context)
                  ? widget.height * 0.032
                  : widget.height * 0.12),
          height: widget.height,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: widget.height * 0.2,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Work Manager App',
                      style: ralewayStyle.copyWith(
                        fontSize: 25.0,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.normal,
                      )),
                ])),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: ' Log In 👇',
                      style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.blueDarkColor,
                        fontSize: 25.0,
                      ))
                ])),
                SizedBox(
                  height: widget.height * 0.02,
                ),
                Text(
                  'Hey,Enter your details to get login \ninto your account',
                  style: ralewayStyle.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(
                  height: widget.height * 0.064,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'User Name',
                    style: ralewayStyle.copyWith(
                      fontSize: 12.0,
                      color: AppColors.blueDarkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6.0,
                ),
                Container(
                  height: 50.0,
                  width: widget.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: userNameController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.verified_user_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter your User Name',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: widget.height * 0.014,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Password',
                    style: ralewayStyle.copyWith(
                      fontSize: 12.0,
                      color: AppColors.blueDarkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6.0,
                ),
                Container(
                  height: 50.0,
                  width: widget.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: passwordController,
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
                                : const Icon(Icons
                                    .no_encryption_gmailerrorred_outlined)),
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.security),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter Your Password',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: widget.height * 0.03,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: ralewayStyle.copyWith(
                          fontSize: 12.0,
                          color: AppColors.blueDarkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
                SizedBox(
                  height: widget.height * 0.05,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      var usrName = userNameController.text;
                      var password = passwordController.text;
                      if (usrName.isEmpty) {
                        glb.showSnackBar(
                            context, 'Error', 'Please Provide User Name');
                        return;
                      }

                      if (password.isEmpty) {
                        glb.showSnackBar(
                            context, 'Error', 'Please Provide Password');
                        return;
                      }
                      

                      showLoaderDialog(context);
                      loginAsync(usrName, password);
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70.0, vertical: 18.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.deepOrange),
                      child: Text(
                        'Login In',
                        style: ralewayStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          )),
    );
  }

  loginAsync(String usrName, String password) async {
    var tlvStr =
        "select usrid,usrname,password,contactno,email,rolid,role,type,level from tskmgmt.tusertbl,tskmgmt.uroletbl where usrid=uid and usrname='$usrName' and uroletbl.status='1' and tusertbl.status='1' ";
    print(" login tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));

      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          Navigator.pop(context);
          glb.showSnackBar(context, 'Error', 'You are not registered');
          return;
        } else if (res.contains("ErrorCode#8")) {
          Navigator.pop(context);
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");
            var usrid = userMap['1'];
            var usrname = userMap['2'];
            var rcvpswd = userMap['3'];
            var contactno = userMap['4'];
            var email = userMap['5'];
            var rolid = userMap['6'];
            var role = userMap['7'];
            var type = userMap['8'];
            var level = userMap['9'];

            glb.userLevel = level.toString();
            glb.userID = usrid;
            glb.userName = usrname;
            List<String> roleLst = glb.strToLst2(role);
            List<String> usridLst = glb.strToLst2(usrid);
            List<String> usrNameLst = glb.strToLst2(usrname);

            print('glb role: $roleLst');
            SharedPreferenceUtils.saveList_val('uroleLst', roleLst);
            SharedPreferenceUtils.saveList_val('usridLst', usridLst);
            SharedPreferenceUtils.saveList_val('usrNameLst', usrNameLst);

            if (rcvpswd.contains(glb.passWord) == false) {
              print('Wrong password');
              glb.showSnackBar(context, 'Password Error', 'Wrong Password');
              Navigator.pop(context);
              return;
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, MultiProfileRoute);
            }
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);
      glb.handleErrors(e, context);
    }

    return "Success";
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
          margin: const EdgeInsets.only(left: 7),
          child: const Text("Loading..."),
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: showLoading,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

bool showLoading = false;
