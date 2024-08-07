// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/models/monitormodels/cityfiltermodel.dart';
import 'package:work_manager/models/monitormodels/empfiltermodel.dart';
import 'package:work_manager/models/monitormodels/phasefiltermodel.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SummaryMonitorPage extends StatefulWidget {
  const SummaryMonitorPage({super.key});

  @override
  State<SummaryMonitorPage> createState() => _SummaryMonitorPageState();
}

class _SummaryMonitorPageState extends State<SummaryMonitorPage> {
  List<_BarChartData> dataBar = [];
  List<_BarChartCityData> dataCityBar = [];
  List<_BarChartPhaseData> dataPhase = [];
  late TooltipBehavior _tooltipBar;
  late TooltipBehavior _tooltipPhase;
  late TooltipBehavior _tooltipCityBar;
  bool _showData = true,
      _showCountData = true,
      _showInstTypeData = true,
      _empOnly = false,
      _isLoading = true,
      isCached = false;
  var callsDone = '0', countInstType = '0', onlineDemo = '0', cityCount = '0';
  List instTypeNameLst = [], cityNameLst = [];
  List phaseNameLst = [];
  List<PhaseFilter> phaseFilter = [];
  var filter = '',
      uid = '',
      selectedEmpName = '',
      filterCityCount = '',
      tableFilter = '',
      countFilter = '',
      dateFilter = '',
      userRole = '';
  List allCityIDLst = [];
  List allCityNameLst = [];
  bool _showSelectedType = false, showFilters = false;
  String _dateCount = '';
  String _range = '';

  void getDefaults() async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userID = glb.prefs!.getString('userId')!;
    glb.fdt = '';
    glb.Tdt = '';
    filter = " and taskphase.ownerid='${glb.userID}'";
    tableFilter = "";
    countFilter = "and tasktbl.ownerid='${glb.userID}'";
    dateFilter =
        "tasktbl.date >=CURRENT_DATE-7 and tasktbl.date <= CURRENT_DATE";
    setState(() {
      _empOnly = true;
    });
    OnlineDemoAsync(context);
    CallsDoneAsync(context);
    InstTypeGraphAsync(context);
    CityGraphAsync(context);
    PhaseGraphAsync(context);
    pullEmployees(context);
    PullCityAsync();
    PullPhasesAsync();
  }

  @override
  void initState() {
    /* dataBar = [
      _BarChartData('Calls', 12),
      _BarChartData('Leads', 15),
      _BarChartData('Demos', 10),
      _BarChartData('Closed', 6.4),
      _BarChartData('Pending', 14)
    ]; */
    getDefaults();
    _tooltipBar = TooltipBehavior(enable: true);
    _tooltipCityBar = TooltipBehavior(enable: true);
    _tooltipPhase = TooltipBehavior(enable: true);

    super.initState();
  }

  pullEmployees(BuildContext context) async {
    empFilter = [];
    if (glb.empMap[glb.Prjid] != null) {
      glb.uidLst = glb.empMap[glb.Prjid]!.uid;
      glb.roleLst = glb.empMap[glb.Prjid]!.role;
      glb.Empolyees = glb.empMap[glb.Prjid]!.Empolyees;
      glb.openforLst = glb.empMap[glb.Prjid]!.openFor;
      print('glb emp: ${glb.Empolyees}');
      for (int i = 0; i < glb.uidLst.length; i++) {
        var uid = glb.uidLst.elementAt(i).toString();
        var name = glb.Empolyees.elementAt(i).toString();
        var role = glb.roleLst.elementAt(i).toString();
        var openFor = glb.openforLst.elementAt(i).toString();
        empFilter.add(EmpFilter(
            EmpID: uid, EmpName: name, EmpRole: role, EmpOpenFor: openFor));
      }
      return '';
    }

    var tlvStr =
        "select usrname,role,openfor,tusertbl.usrid From tskmgmt.prjassigntbl,tskmgmt.uroletbl,tskmgmt.tusertbl where tusertbl.usrid=uid and tusertbl.usrid=prjassigntbl.usrid and pjid=1";

    print(" pull emp tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          print('err 2');
          glb.showSnackBar(context, 'Error', 'No  Data Found');
          return;
        } else if (res.contains("ErrorCode#8")) {
          print('err 8');
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("empPullMap:$userMap");

            var usrnm = userMap['1'];
            var role = userMap['2'];
            var openfor = userMap['3'];
            var uid = userMap['4'];

            List usrnmLst = glb.strToLst(usrnm);
            glb.uidLst = glb.strToLst(uid);
            glb.Empolyees = glb.strToLst2(usrnm);
            glb.roleLst = glb.strToLst(role);
            glb.openforLst = glb.strToLst(openfor);
            //glb.EmpList? obj;
            //print(obj);
            for (int i = 0; i < glb.uidLst.length; i++) {
              var uid = glb.uidLst.elementAt(i).toString();
              var name = glb.Empolyees.elementAt(i).toString();
              var role = glb.roleLst.elementAt(i).toString();
              var openFor = glb.openforLst.elementAt(i).toString();
              empFilter.add(EmpFilter(
                  EmpID: uid,
                  EmpName: name,
                  EmpRole: role,
                  EmpOpenFor: openFor));
            }
            if (glb.EmpList == null) {
              glb.EmpList? obj;
              obj = glb.EmpList();
              obj.Empolyees = glb.Empolyees;
              obj.role = glb.roleLst;
              obj.uid = glb.uidLst;
              obj.openFor = glb.openforLst;
              glb.empMap[glb.Prjid] = obj;
              print('obj ${obj.role}');
            }
            // print(uidLst);
            // print(Empolyees);
            // print(openforLst);
            // print(roleLst);
            print('usrnm lst : $usrnmLst');
            print('role: $role');
            print('opfor:: $openfor');
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  OnlineDemoAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;

    userRole = glb.prefs!.getString('urole')!;

    setState(() {
      if (userRole == 'Super Admin') {
        showFilters = true;
      }
      instTypeNameLst.clear();
      cityNameLst.clear();
      phaseNameLst.clear();
      dataBar = [];
      dataCityBar = [];
      dataPhase = [];
      _showData = true;
      callsDone = '0';
      countInstType = '0';
      onlineDemo = '0';
      cityCount = '0';
      _showCountData = true;
      print('caaaalls done::$callsDone');
    });
    glb.prefs = await SharedPreferences.getInstance();
    glb.userID = glb.prefs!.getString('userId')!;

    var tlvStr =
        "select count(*) from ${tableFilter}tskmgmt.taskphase,tskmgmt.tasktbl where $dateFilter  and tasktbl.status=2 and taskphase.taskid=tasktbl.taskid and taskphase.status=1  and phase='online demo' $filter;";

    print(" Task tlv: $tlvStr");
    String url = glb.endPoint;
    print(" Task tlv: ${glb.endPoint}");

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          // glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            onlineDemo = taskMap['1'];

            setState(() {
              _isLoading = false;
              _showData = false;
              isCached = true;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  CallsDoneAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;

    setState(() {
      _showData = true;
      _showCountData = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    var filterr = '';
    if (_empOnly) {
      filterr = countFilter;
    } else {
      filterr = filter;
    }
    print(_empOnly);
    var tlvStr =
        "select count(*) from ${tableFilter}tskmgmt.tasktbl where $dateFilter and status=2 $filterr;";

    print("Total Calls DOne tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          // glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
          setState(() {
            _isLoading = false;
            _showCountData = false;
            isCached = true;
            _empOnly = false;
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            callsDone = taskMap['1'];

            setState(() {
              _isLoading = false;
              _showCountData = false;
              isCached = true;
              _empOnly = false;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  InstTypeGraphAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;

    setState(() {
      _showData = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');

    var tlvStr =
        "select count(*),insttype from ${tableFilter}tskmgmt.taskphase,tskmgmt.tasktbl where $dateFilter  and  taskphase.taskid=tasktbl.taskid and taskphase.status=1 $filter group by insttype ;";

    print(" Calls DOne tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          //glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            countInstType = taskMap['1'];
            var instTypeName = taskMap['2'];

            instTypeNameLst = glb.strToLst(instTypeName);
            List countInstTypeLst = glb.strToLst(countInstType);

            for (int i = 0; i < instTypeNameLst.length; i++) {
              var cnt = countInstTypeLst.elementAt(i).toString();
              var instType = instTypeNameLst.elementAt(i).toString();

              /* if (instType.length > 6) {
                instType = instType.substring(0, 6);
              } */
              var cnt1 = double.parse(cnt);
              var color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0);
              dataBar.add(_BarChartData(instType, cnt1, color));
            }

            setState(() {
              _isLoading = false;
              _showInstTypeData = false;
              isCached = true;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  CityGraphAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;

    setState(() {
      _showData = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');

    var tlvStr =
        "select count(*),cityname from tskmgmt.citytbl,tskmgmt.taskphase,tskmgmt.tasktbl where $dateFilter  and  taskphase.taskid=tasktbl.taskid and taskphase.status=1 and citytbl.cityid=tasktbl.cityid $filterCityCount group by cityname ;";

    print(" Calls DOne tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          //glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            cityCount = taskMap['1'];
            var cityName = taskMap['2'];
            List cityCntLst = glb.strToLst(cityCount);
            cityNameLst = glb.strToLst(cityName);

            for (int i = 0; i < cityNameLst.length; i++) {
              var cnt = cityCntLst.elementAt(i).toString();
              var cityname = cityNameLst.elementAt(i).toString();

              /* if (cityname.length > 6) {
                cityname = cityname.substring(0, 6);
              } */
              var cnt1 = double.parse(cnt);
              var color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0);
              dataCityBar.add(_BarChartCityData(cityname, cnt1, color));
            }

            setState(() {
              _isLoading = false;
              _showData = false;
              isCached = true;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  PhaseGraphAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;

    setState(() {
      _showData = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');

    var tlvStr =
        "select count(*),phase from ${tableFilter}tskmgmt.taskphase,tskmgmt.tasktbl where $dateFilter  and  taskphase.taskid=tasktbl.taskid and taskphase.status=1 $filter group by phase;";

    print(" Calls DOne tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          //glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            var phaseCnt = taskMap['1'];
            var phaseName = taskMap['2'];

            phaseNameLst = glb.strToLst(phaseName);
            List phaseCntLst = glb.strToLst(phaseCnt);

            for (int i = 0; i < phaseCntLst.length; i++) {
              var cnt = phaseCntLst.elementAt(i).toString();
              var phname = phaseNameLst.elementAt(i).toString();

              /* if (phname.length > 7) {
                phname = phname.substring(0, 7);
              } */
              var cnt1 = double.parse(cnt);
              var color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0);
              dataPhase.add(_BarChartPhaseData(phname, cnt1, color));
            }

            setState(() {
              _isLoading = false;
              _showInstTypeData = false;
              isCached = true;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  PullCityAsync() async {
    //select cityid,cityname from tskmgmt.citytbl
    setState(() {
      cityFilter = [];
    });
    var tlvStr = "select cityid,cityname from tskmgmt.citytbl;";

    print(" Calls DOne tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          // glb.showSnackBar(context, 'Error', 'No Tasks Assigned');

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> cityMap = json.decode(response.body);
            print("cityMap:$cityMap");

            var cityID = cityMap['1'];
            var cityName = cityMap['2'];
            allCityIDLst = glb.strToLst(cityID);
            allCityNameLst = glb.strToLst(cityName);

            for (int i = 0; i < allCityIDLst.length; i++) {
              var cityid = allCityIDLst.elementAt(i).toString();
              var citynm = allCityNameLst.elementAt(i).toString();
              cityFilter.add(CityFilter(cityID: cityid, cityName: citynm));
            }
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  PullPhasesAsync() async {
    //select cityid,cityname from tskmgmt.citytbl
    setState(() {
      phaseFilter = [];
    });
    var tlvStr = "select phase,phasename from tskmgmt.nextphases;";

    print(" phase tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(dict));
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          // glb.showSnackBar(context, 'Error', 'No Tasks Assigned');

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> phaseMap = json.decode(response.body);
            print("phaseMap:$phaseMap");

            var phaseID = phaseMap['1'];
            var phaseName = phaseMap['2'];
            List phaseIDLst = glb.strToLst(phaseID);
            List phaseNameLst = glb.strToLst(phaseName);

            for (int i = 0; i < phaseIDLst.length; i++) {
              var phaseid = phaseIDLst.elementAt(i).toString();
              var phasenm = phaseNameLst.elementAt(i).toString();
              phaseFilter
                  .add(PhaseFilter(phaseID: phaseid, phaseName: phasenm));
            }
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: _MainHeaders()),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 2.0,
                  ),
                  _HeadingSection(),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWidget(
                          title: 'Filter Specific Reports',
                          fontsize: 14,
                          color: AppColors.mainBlueColor),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2012, 3, 5),
                                  maxTime: DateTime(2030, 6, 7),
                                  theme: const DatePickerTheme(
                                      itemStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      doneStyle: TextStyle(fontSize: 16)),
                                  onChanged: (date) {}, onConfirm: (date) {
                                var addZero = '';
                                setState(() {
                                  if (date.month < 10) {
                                    addZero = '0';
                                  } else {
                                    addZero = '';
                                  }
                                  glb.fdt =
                                      '${date.year}-$addZero${date.month}-${date.day}';
                                  glb.fdt = date.toString();
                                  var parts = glb.fdt.split(" ");
                                  glb.fdt = parts[0].trim();
                                });
                                print(
                                    'confirm ${date.year}-$addZero${date.month}-${date.day}');
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.green),
                                TextWidget(
                                    title: 'From Date: ${glb.fdt}',
                                    fontsize: 8,
                                    color: AppColors.greyColor)
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (glb.fdt.isEmpty) {
                                glb.showSnackBar(context, 'Error',
                                    'Please Select the From Date First');
                                return;
                              }
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2012, 3, 5),
                                  maxTime: DateTime(2030, 6, 7),
                                  theme: DatePickerTheme(
                                      itemStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      doneStyle: TextStyle(fontSize: 16)),
                                  onChanged: (date) {}, onConfirm: (date) {
                                var addZero = '';
                                setState(() {
                                  if (date.month < 10) {
                                    addZero = '0';
                                  } else {
                                    addZero = '';
                                  }

                                  glb.Tdt =
                                      '${date.year}-$addZero${date.month}-${date.day}';
                                  glb.Tdt = date.toString();
                                  var parts = glb.Tdt.split(" ");
                                  glb.Tdt = parts[0].trim();

                                  //Need to add date filter here

                                  setState(() {
                                    dateFilter =
                                        "tasktbl.date >='${glb.fdt}' and tasktbl.date <= '${glb.Tdt}'";
                                    _empOnly = true;
                                  });
                                  OnlineDemoAsync(context);
                                  CallsDoneAsync(context);
                                  InstTypeGraphAsync(context);
                                  CityGraphAsync(context);
                                  PhaseGraphAsync(context);
                                });
                                print(
                                    'confirm ${date.year}-$addZero${date.month}-${date.day}');
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.pink),
                                TextWidget(
                                    title: 'To Date: ${glb.Tdt}',
                                    fontsize: 8,
                                    color: AppColors.greyColor)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  showFilters
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              filter = '';
                                              countFilter = '';
                                              tableFilter = '';
                                              OnlineDemoAsync(context);
                                              CallsDoneAsync(context);
                                              InstTypeGraphAsync(context);
                                              CityGraphAsync(context);
                                              PhaseGraphAsync(context);
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Ink(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                children: const [
                                                  Icon(Icons.all_inclusive,
                                                      color: Colors.red),
                                                  TextWidget(
                                                      title: 'All',
                                                      fontsize: 10,
                                                      color:
                                                          AppColors.greyColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showCityFilter(
                                                context, width, height);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Ink(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .location_city_rounded,
                                                      color: Colors.blue),
                                                  TextWidget(
                                                      title: 'City Specific',
                                                      fontsize: 8,
                                                      color:
                                                          AppColors.greyColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showPhaseFilter(
                                                context, width, height);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Ink(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .panorama_photosphere_select,
                                                      color: Colors.green),
                                                  TextWidget(
                                                      title: 'Phase Specific',
                                                      fontsize: 8,
                                                      color:
                                                          AppColors.greyColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            //showFilter(context, width, height);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Ink(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                children: [
                                                  Icon(Icons.location_city,
                                                      color: Colors.deepPurple),
                                                  TextWidget(
                                                      title: 'Region Specific',
                                                      fontsize: 8,
                                                      color:
                                                          AppColors.greyColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showFilter(context, width, height);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Ink(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Icon(Icons.reduce_capacity,
                                                      color: Colors.deepOrange),
                                                  TextWidget(
                                                      title:
                                                          'Employee Specific',
                                                      fontsize: 8,
                                                      color:
                                                          AppColors.greyColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            _showInstTypeData
                                ? TextWidget(
                                    title: selectedEmpName,
                                    fontsize: 12,
                                    color: AppColors.mainBlueColor)
                                : Text(''),
                            SizedBox(
                              height: height * 0.02,
                            ),
                          ],
                        )
                      : const _HeadSection1(
                          title: 'Weekly Stats', icon: Icons.query_stats),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  _showCountData
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.withOpacity(0.2),
                          highlightColor: Colors.grey.withOpacity(0.1),
                          enabled: _showCountData,
                          child: _WeeklyStatsCards(
                              height: height,
                              width: width,
                              callCount: callsDone,
                              onlineDemoCount: onlineDemo))
                      : _WeeklyStatsCards(
                          height: height,
                          width: width,
                          callCount: callsDone,
                          onlineDemoCount: onlineDemo),
                  SizedBox(height: height * 0.03),
                  const _HeadSection1(
                      title: 'Institution Type Graph', icon: Icons.graphic_eq),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: instTypeNameLst.length + 10,
                              interval: 15),
                          tooltipBehavior: _tooltipBar,
                          series: <ChartSeries<_BarChartData, String>>[
                            ColumnSeries<_BarChartData, String>(
                                dataSource: dataBar,
                                xValueMapper: (_BarChartData data, _) => data.x,
                                yValueMapper: (_BarChartData data, _) => data.y,
                                name: 'Institution Type',
                                color: AppColors.mainBlueColor)
                          ]),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  const _HeadSection1(
                      title: 'CityWise Graph', icon: Icons.location_city),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: cityNameLst.length + 10,
                              interval: 15),
                          tooltipBehavior: _tooltipCityBar,
                          series: <ChartSeries<_BarChartCityData, String>>[
                            ColumnSeries<_BarChartCityData, String>(
                                dataSource: dataCityBar,
                                xValueMapper: (_BarChartCityData data, _) =>
                                    data.x,
                                yValueMapper: (_BarChartCityData data, _) =>
                                    data.y,
                                name: 'City Name',
                                color: Colors.amber)
                          ]),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  const _HeadSection1(
                      title: 'PhaseWise Graph', icon: Icons.stacked_bar_chart),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: phaseNameLst.length + 10,
                              interval: 15),
                          tooltipBehavior: _tooltipPhase,
                          series: <ChartSeries<_BarChartPhaseData, String>>[
                            ColumnSeries<_BarChartPhaseData, String>(
                                dataSource: dataPhase,
                                xValueMapper: (_BarChartPhaseData data, _) =>
                                    data.x,
                                yValueMapper: (_BarChartPhaseData data, _) =>
                                    data.y,
                                name: 'Phase Name',
                                color: Colors.green)
                          ]),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  TextEditingController searchController = TextEditingController();
  void showFilter(BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                      title: 'Employee Filter',
                      fontsize: 16,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              content: setupAlertDialoadContainer());
        });
  }

  Widget setupAlertDialoadContainer() {
    return SizedBox(
      height: 600.0, // Change as per your requirement
      width: 300.0,
      // Change as per your requirement
      child: Column(
        children: [
          Container(
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: AppColors.backColor,
            ),
            child: TextFormField(
              onChanged: ((value) {
                // print('Value::$value');
                // filterSearchResults(value);
              }),
              controller: searchController,
              style: ralewayStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.blueDarkColor,
                  fontSize: 12.0),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  contentPadding: const EdgeInsets.only(top: 16.0),
                  hintText: 'Search Employee Here',
                  hintStyle: ralewayStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.blueDarkColor.withOpacity(0.5),
                      fontSize: 12.0)),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  filter = "";
                  filterCityCount = ""; //Removes where particular cityid
                  tableFilter = "";
                  OnlineDemoAsync(context);
                  CallsDoneAsync(context);
                  InstTypeGraphAsync(context);
                  CityGraphAsync(context);
                  PhaseGraphAsync(context);
                  Navigator.pop(context);
                });
              },
              child: Ink(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextWidget(
                      title: 'All Employees',
                      fontsize: 16,
                      color: AppColors.mainBlueColor),
                ),
              ),
            ),
          ),
          empFilter.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, _) => Container(
                      height: 0.5,
                      color: AppColors.greyColor,
                    ),
                    itemCount: empFilter.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            var uid = empFilter[index].EmpID;
                            selectedEmpName = empFilter[index].EmpName;
                            setState(() {
                              selectedEmpName = empFilter[index].EmpName;
                              _showInstTypeData = true;
                              _empOnly = true;
                              filter = " and taskphase.ownerid='$uid'";
                              tableFilter = "";
                              countFilter = "and tasktbl.ownerid='$uid'";
                              OnlineDemoAsync(context);
                              CallsDoneAsync(context);
                              InstTypeGraphAsync(context);
                              CityGraphAsync(context);
                              PhaseGraphAsync(context);

                              Navigator.pop(context);
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _EmpFilterCard(model: empFilter[index])),
                        ),
                      );
                    },
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No Employees Found'),
                ),
        ],
      ),
    );
  }

  TextEditingController citySearchController = TextEditingController();
  void showCityFilter(BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                      title: 'City Filter',
                      fontsize: 16,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              content: setupAlertDialogCityContainer());
        });
  }

  Widget setupAlertDialogCityContainer() {
    return SizedBox(
      height: 600.0, // Change as per your requirement
      width: 300.0,
      // Change as per your requirement
      child: Column(
        children: [
          Container(
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: AppColors.backColor,
            ),
            child: TextFormField(
              onChanged: ((value) {
                // print('Value::$value');
                // filterSearchResults(value);
              }),
              controller: searchController,
              style: ralewayStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.blueDarkColor,
                  fontSize: 12.0),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  contentPadding: const EdgeInsets.only(top: 16.0),
                  hintText: 'Search City Here',
                  hintStyle: ralewayStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.blueDarkColor.withOpacity(0.5),
                      fontSize: 12.0)),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  filter = "and tasktbl.cityid=citytbl.cityid";
                  filterCityCount = ""; //Removes where particular cityid
                  tableFilter = "tskmgmt.citytbl,";
                  OnlineDemoAsync(context);
                  CallsDoneAsync(context);
                  InstTypeGraphAsync(context);
                  CityGraphAsync(context);
                  PhaseGraphAsync(context);
                  Navigator.pop(context);
                });
              },
              child: Ink(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextWidget(
                      title: 'All Cities',
                      fontsize: 16,
                      color: AppColors.mainBlueColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          cityFilter.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, _) => Container(
                      height: 0.5,
                      color: AppColors.greyColor,
                    ),
                    itemCount: cityFilter.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            var cityID = cityFilter[index].cityID;
                            print('citySelected::$cityID');
                            setState(() {
                              filter =
                                  "and tasktbl.cityid=citytbl.cityid and tasktbl.cityid='$cityID'";
                              filterCityCount = "and tasktbl.cityid='$cityID'";
                              tableFilter = "tskmgmt.citytbl,";
                              OnlineDemoAsync(context);
                              CallsDoneAsync(context);
                              InstTypeGraphAsync(context);
                              CityGraphAsync(context);
                              PhaseGraphAsync(context);
                              Navigator.pop(context);
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _CityFilterCard(model: cityFilter[index])),
                        ),
                      );
                    },
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No City Found'),
                ),
        ],
      ),
    );
  }

  TextEditingController phaseSearchController = TextEditingController();
  void showPhaseFilter(BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                      title: 'Phase Filter',
                      fontsize: 16,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              content: setupAlertDialogPhaseContainer());
        });
  }

  Widget setupAlertDialogPhaseContainer() {
    return SizedBox(
      height: 600.0, // Change as per your requirement
      width: 300.0,
      // Change as per your requirement
      child: Column(
        children: [
          Container(
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: AppColors.backColor,
            ),
            child: TextFormField(
              onChanged: ((value) {
                // print('Value::$value');
                // filterSearchResults(value);
              }),
              controller: phaseSearchController,
              style: ralewayStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.blueDarkColor,
                  fontSize: 12.0),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  contentPadding: const EdgeInsets.only(top: 16.0),
                  hintText: 'Search Phase Name Here',
                  hintStyle: ralewayStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.blueDarkColor.withOpacity(0.5),
                      fontSize: 12.0)),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  filter = "";
                  filterCityCount = ""; //Removes where particular cityid
                  tableFilter = "";
                  OnlineDemoAsync(context);
                  CallsDoneAsync(context);
                  InstTypeGraphAsync(context);
                  CityGraphAsync(context);
                  PhaseGraphAsync(context);
                  Navigator.pop(context);
                });
              },
              child: Ink(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextWidget(
                      title: 'All Phases',
                      fontsize: 16,
                      color: AppColors.mainBlueColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          cityFilter.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, _) => Container(
                      height: 0.5,
                      color: AppColors.greyColor,
                    ),
                    itemCount: phaseFilter.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            var phaseName = phaseFilter[index].phaseName;

                            setState(() {
                              _empOnly = true;
                              filter = "and phase='$phaseName'";
                              filterCityCount = "";
                              tableFilter = "";
                              OnlineDemoAsync(context);
                              CallsDoneAsync(context);
                              InstTypeGraphAsync(context);
                              CityGraphAsync(context);
                              PhaseGraphAsync(context);
                              Navigator.pop(context);
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  _PhaseFilterCard(model: phaseFilter[index])),
                        ),
                      );
                    },
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No Phases Found'),
                ),
        ],
      ),
    );
  }

  void showDateFilter(BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                      title: 'Date Specific Filter',
                      fontsize: 16,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              content: setupAlertDialogDatePicker());
        });
  }

  Widget setupAlertDialogDatePicker() {
    return SizedBox(
      height: 600.0, // Change as per your requirement
      width: 300.0,
      // Change as per your requirement
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No Phases Found'),
          ),
        ],
      ),
    );
  }
}

List<EmpFilter> empFilter = [];
List<CityFilter> cityFilter = [];

class _PhaseFilterCard extends StatelessWidget {
  const _PhaseFilterCard({
    Key? key,
    required this.model,
  }) : super(key: key);

  final PhaseFilter model;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: CircleAvatar(
            radius: 15.0,
            backgroundImage: NetworkImage(
                'https://media.discordapp.net/attachments/1008571078211280957/1087760091920486460/Quicktunes_person_giving_online_demo_for_an_erp_software_cc29619d-c127-4433-b120-f772fc98a6e6.png?width=812&height=812'),
            backgroundColor: Colors.transparent,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: TextWidget(
                    title: model.phaseName,
                    fontsize: 10,
                    color: AppColors.blueDarkColor),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _CityFilterCard extends StatelessWidget {
  const _CityFilterCard({
    Key? key,
    required this.model,
  }) : super(key: key);

  final CityFilter model;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: CircleAvatar(
            radius: 15.0,
            backgroundImage: NetworkImage(
                'https://www.shutterstock.com/image-photo/day-night-rooftop-view-mahanakhon-260nw-1396457765.jpg'),
            backgroundColor: Colors.transparent,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: TextWidget(
                    title: model.cityName,
                    fontsize: 10,
                    color: AppColors.mainBlueColor),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _EmpFilterCard extends StatelessWidget {
  const _EmpFilterCard({
    Key? key,
    required this.model,
  }) : super(key: key);

  final EmpFilter model;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: CircleAvatar(
            radius: 15.0,
            backgroundImage: NetworkImage(
                'https://www.shutterstock.com/image-photo/tasks-word-on-wooden-cubes-260nw-1904598853.jpg'),
            backgroundColor: Colors.transparent,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: TextWidget(
                    title: model.EmpName,
                    fontsize: 10,
                    color: AppColors.mainBlueColor),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Container(
                width: double.infinity,
                child: TextWidget(
                    title: model.EmpRole,
                    fontsize: 8,
                    color: AppColors.textColor),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _HeadSection1 extends StatelessWidget {
  const _HeadSection1({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Icon(
          icon,
          color: AppColors.mainBlueColor,
        )
      ],
    );
  }
}

class _WeeklyStatsCards extends StatelessWidget {
  const _WeeklyStatsCards({
    Key? key,
    required this.height,
    required this.width,
    required this.callCount,
    required this.onlineDemoCount,
  }) : super(key: key);
  final double height;
  final double width;
  final String callCount;
  final String onlineDemoCount;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatsCardLayout(
                width: width,
                color: Colors.deepOrange,
                title: 'Calls Done',
                index: 0,
                height: height,
                count: callCount,
                icon: Icons.call_made_outlined,
              ),
              _StatsCardLayout(
                width: width,
                color: Colors.deepPurple,
                title: "Online Demo's",
                index: 1,
                height: height,
                count: onlineDemoCount,
                icon: Icons.online_prediction_outlined,
              ),
            ],
          ),
          SizedBox(
            height: height * 0.02,
          ),
        ],
      ),
    );
  }
}

class _StatsCardLayout extends StatelessWidget {
  const _StatsCardLayout({
    Key? key,
    required this.width,
    required this.color,
    required this.title,
    required this.index,
    required this.height,
    required this.count,
    required this.icon,
  }) : super(key: key);

  final double width;
  final Color color;
  final String title;
  final int index;
  final double height;
  final String count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: width * 0.47,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(1, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(icon, color: AppColors.whiteColor),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Text(
                      title,
                      style: ralewayStyle.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueDarkColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(count,
                    style: ralewayStyle.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor)),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.greenAccent,
                      size: 15.0,
                    ),
                    Text('13 % vs',
                        style: ralewayStyle.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    SizedBox(
                      width: width * 0.01,
                    ),
                    Text('last 7 days',
                        style: ralewayStyle.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadingSection extends StatelessWidget {
  const _HeadingSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello ${userName} 👋',
            style: ralewayStyle.copyWith(
                fontSize: 16.0,
                color: AppColors.mainBlueColor,
                fontWeight: FontWeight.w900)),
        Row(
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 15.0,
              color: Colors.green,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('Monitor All Your Efforts Here',
                style: ralewayStyle.copyWith(
                    fontSize: 10.0,
                    color: AppColors.blueDarkColor,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}

class _BarChartData {
  _BarChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class _BarChartCityData {
  _BarChartCityData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class _BarChartPhaseData {
  _BarChartPhaseData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class _MainHeaders extends StatelessWidget {
  const _MainHeaders({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Summary Monitor',
            style: ralewayStyle.copyWith(
              fontSize: 24.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              //Navigator.pushNamed(context, AddEmployeeRoute);
            },
            borderRadius: BorderRadius.circular(50),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.green,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.summarize,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
