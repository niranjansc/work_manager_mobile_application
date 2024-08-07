import 'package:flutter/material.dart';
import 'package:work_manager/administratorPages/addNewEmployee.dart';
import 'package:work_manager/administratorPages/allProjects.dart';
import 'package:work_manager/administratorPages/assignedprojecttoemployee.dart';
import 'package:work_manager/administratorPages/createprojects.dart';
import 'package:work_manager/administratorPages/employeemanagement.dart';
import 'package:work_manager/administratorPages/taskmanagement/addtask.dart';
import 'package:work_manager/administratorPages/taskmanagement/alltask.dart';
import 'package:work_manager/administratorPages/taskmanagement/nextphase.dart';
import 'package:work_manager/analysisPages/analysisMainPage.dart';
import 'package:work_manager/mainPages/loginScreen.dart';
import 'package:work_manager/mainPages/mainScreen.dart';
import 'package:work_manager/mainPages/multipleProfile.dart';
import 'package:work_manager/mainPages/splashScreen.dart';
import 'package:work_manager/monitorPages/currentTaskmonitor.dart';
import 'package:work_manager/monitorPages/summarymonitor.dart';
import 'package:work_manager/monitorPages/taskmonitor.dart';
import 'package:work_manager/regionManagement/addRegion.dart';
import 'package:work_manager/regionManagement/regionManagement.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/settingsPages/accountMainScreen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  // print('generateRoute: ${settings.name}');
  switch (settings.name) {
    case SplashScreenRoute:
    return _getPageRoute(const SplashScreen());
    case LoginRoute:
      return _getPageRoute(const LoginScreen());
    case MultiProfileRoute:
      return _getPageRoute(const MultiProfilePage());
    case HomeRoute:
      return _getPageRoute(const HomePageScreen());
    // case AnalysisDetailedLeadCallRoute:
    //   return _getPageRoute(const LeadAnalysisView());
    case AnalysisMainRoute:
      return _getPageRoute(const AnalysisMainPage());
    case CreateProjectsRoute:
      return _getPageRoute(const CreateProjectsPage());
    case AllProjectsRoute:
      return _getPageRoute(const AllProjectsPage());
    case EmployeeManagementRoute:
      return _getPageRoute(const EmployeeManagementPage());
    case RegionManagementRoute:
      return _getPageRoute(const RegionManagement());
    case CreateRegionRoute:
      return _getPageRoute(const CreateRegion());
    case AddEmployeeRoute:
      return _getPageRoute(const CreateNewEmployee());
    case AddTaskRoute:
      return _getPageRoute(const AddTaskPage());
    case LoadTaskRoute:
      return _getPageRoute(const AllTaskPage());
    case NextPhaseRoute:
      return _getPageRoute(const NextPhase());
    case TaskMonitorRoute:
      return _getPageRoute(const TaskMonitorPage());
    case SummaryMonitorRoute:
      return _getPageRoute(const SummaryMonitorPage());
    case CurrentTaskRoute:
      return _getPageRoute(const CurrentTaskMonitor());
    case ProjectAssignedEmployeeRoute:
      return _getPageRoute(const AssignedEmployeeProjectPage());
    case AccountManagementRoute:
      return _getPageRoute(const AccountManagementPage());

    default:
      return _getPageRoute(const SplashScreen());
  }
}

PageRoute _getPageRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
