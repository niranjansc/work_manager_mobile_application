import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _loadAsyncData() async {
    glb.prefs = await SharedPreferences.getInstance();

    var userId = glb.prefs!.getString('userId');
    if (userId != null && userId!.isEmpty == false) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Navigator.pushNamed(context, MultiProfileRoute);
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, LoginRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      _loadAsyncData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height=  MediaQuery.of(context).size.height;
                var width= MediaQuery.of(context).size.width;
    return SafeArea(
      left: false,
      top: false,
      right: false,
      bottom: false,
      child: SizedBox.expand(
        child: Stack(children: [
          
          Container(
              color: Colors.white,
              child: Image.asset(
                'assets/images/worksp.gif',
                height:height,
                width: width,
                // width: 200,
                // height: 400,
              )),
        ]),
      ),
    );
  }
}
