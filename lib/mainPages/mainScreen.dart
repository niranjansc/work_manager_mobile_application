import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/mainPages/tabs/administration.dart';
import 'package:work_manager/mainPages/tabs/monitoring.dart';
import 'package:work_manager/mainPages/tabs/settings.dart';
import 'package:work_manager/mainPages/tabs/task.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int currentIndex = 0;
  var userRole = '';
  bool _isAdmin = false;
  List pages = [
    /* TaskPage(),
    MonitoringPage(),
    AdministrationPage(),
    SettingsPage() */
  ];
  List<BottomNavigationBarItem> bottomBarPages = [];
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  getRole() async {
    glb.prefs = await SharedPreferences.getInstance();
    userRole = glb.prefs!.getString('urole')!;
    print('userRole::$userRole');
    setState(() {
      bottomBarPages.clear();
      pages.clear();
      if (userRole == 'Super Admin') {
        pages = [
          TaskPage(),
          MonitoringPage(),
          AdministrationPage(),
          SettingsPage()
        ];
        bottomBarPages = [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ];
      } else {
        pages = [TaskPage(), MonitoringPage(), SettingsPage()];
        bottomBarPages = [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ];
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        unselectedFontSize: 0,
        selectedFontSize: 0,
        elevation: 0,
        onTap: onTap,
        selectedItemColor: Colors.deepOrange[600],
        unselectedItemColor: Colors.grey.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.whiteColor,
        items: bottomBarPages

        /*[ BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''), ]*/
        ,
      ),
      body: pages[currentIndex],
    );
  }
}
