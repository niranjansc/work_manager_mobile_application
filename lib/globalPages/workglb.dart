library global;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;
import 'package:work_manager/globalPages/cacheglb.dart' as glb;

String endPoint = "http://101.53.149.34:4444/";
String phaseval_filter = '';
String TaskId = '';
String PhaseId = '';
String curTaskName = '', EmpName = '', prjID = '', prjName = '';

List Payable_Lst = [];
int earnings = 0;
int paid = 0;
int balance = 0;

int lastCacheRegionType = 0;
bool assignProject = false;
void showSnackBar(BuildContext context, String alertTxt, String text) {
  Get.snackbar(alertTxt, text, snackPosition: SnackPosition.TOP);
}

String ext_upload_url = "https://d26ksqb4lnqfvh.cloudfront.net/";
String upload_url = "http://164.52.210.25:3335/upload";

SharedPreferences? prefs;
String TaskTyp = 'NA';
String userLevel = "-1",
    userID = "",
    userName = "",
    passWord = "",
    CurRoleName = "";
List<String> PhaseLst = [];
List<String> TaskType = [];
String usr_lvl = '1';
List uidLst = [];
List<String> Empolyees = [];
List roleLst = [];
List openforLst = [];
String roleFilter = "";
late final Map<String, CountryObj> CountryMap = new Map<String, CountryObj>();

class CountryObj {
  late String CountryID;
  late String CounntryName;
  late Map<String, StateObj> StateMap = new HashMap();
}

class StateObj {
  late String StateID;
  late String StateName;
  late Map<String, DistrictObj> DistrictMap = new HashMap();
}

class DistrictObj {
  late String DistrictID;
  late String DistrictName;
  late Map<String, TalukObj> TalukMap = new HashMap();
}

class TalukObj {
  late String TalukID;
  late String TalukName;
  late Map<String, CityObj> CityMap = new HashMap();
}

class CityObj {
  late String CityID;
  late String CityName;
}

var Prjid;
var CountryCache = 1;
var StateCache = 1;
var CityCache = 1;
var DistCache = 1;
var TalukCache = 1;

var region_full_query = 1;
var region_controls = true;
var ActionVal = 1;
String assid = '1';

List<String> CntryLst = [];
List CntryIDLst = [];
String CntryNM = '';
String CntryID = '';

List<String> StateNMLst = [];
List StateIDLst = [];
String StateNM = '';
String StateID = '';

List<String> DistNMLST = [];
List DistIDLst = [];
String DistID = '';
String DistNM = '';

List<String> TalukNMLst = [];
List TalukIDLst = [];
String TalukID = '';
String TalukNM = '';

List<String> CityNMLst = [];
List CityIDLst = [];
String CityID = '';
String CityNM = '';

String CountryTF = ''; //Country Text field
String StateTF = '';
String DistrictTF = '';
String TalukTF = '';
String CityTF = '';

List strToLst(String str) {
  var split = str.toString().split(",");
  return split;
}

List<String> strToLst2(String str) {
  var split = str.toString().split(",");
  return split;
}

handleErrors(Object e, BuildContext context) {
  if (e.toString().contains('Connection failed')) {
    showSnackBar(context, 'Network Error',
        'No Internet Connection Found / Server is Down');
    return;
  }
  print("handle Exception here::$e");
  if (e.toString().contains("XMLHttpRequest")) {
    showSnackBar(context, 'Network Error',
        'No Internet Connection Found / Server is Down');
    return;
  }
  if (e.toString() == "Connection reset by peer") {
    showSnackBar(context, 'Network Error',
        'No Internet Connection Found / Server is Down');
    return;
  }
  if (e.toString().contains("Connection refused")) {
    showSnackBar(context, 'Network Error',
        'No Internet Connection Found / Server is Down');
    return;
  } else if (e.toString().contains("Operation timed out")) {
    showSnackBar(context, 'Network Error', 'Connection Time Out');
    return;
  }
}

List<String> tasks = <String>[
  'Director',
  'TeleCaller',
  'Lead Gen',
  'Connector Gen',
  'BDM',
  'Dev',
  'State Head',
  'Testing',
  'Govt connect',
  'router installer',
  'Franchise',
];
List<EmpList> empol = [];
Map<String, EmpList> empMap = new Map<String, EmpList>();
String TaskTypeVal = TaskType.first;

class EmpList {
  late List uid;
  late List<String> Empolyees;
  late List role;
  late List openFor;
}

bool AssignBtn = true;
bool NextBtn = true;
String fdt = '';
String ftm = '';
String Tdt = '2023-01-11';
String Ttm = '19:44:00.000';
String Fepoch = '0';
String Tepoch = '0';
String holderid = '';
bool assignRegion = false;
String EmpID = '';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

var CntryDDV = ' ';
var StateDDV = ' ';
var DistDDV = ' ';
var TalukDDV = ' ';
var CityDDV = ' ';
List countryLst = ['India'];

String? MCntryNM;
String? McntryID;

bool CountryVis = true;
bool StateVis = true;
bool DistVis = true;
bool TalukVis = true;
bool CityVis = true;
IndexOf(param0, List<String> empolyees) {
  print("employee:$empolyees   param::$param0");
  if (empolyees == null || empolyees.length <= 0) return;
  for (int i = 0; i < empolyees.length; i++) {
    print("empolyees[i]::${empolyees[i]}");
    if (empolyees[i].toString().contains(param0)) return i;
  }
}

showLoaderDialog(BuildContext context, bool isLoading) {
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
    barrierDismissible: isLoading,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
