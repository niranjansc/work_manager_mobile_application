// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import 'package:work_manager/globalPages/cacheglb.dart';
import 'package:work_manager/globalPages/region.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:work_manager/models/employeemodel.dart';
import 'package:work_manager/models/taskmodel.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

import '../../administratorPages/employeemanagement.dart';

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;
  bool _enabled = true;
  List<TaskModel> taskModel = [];
  bool _showData = false,
      _isLoading = true,
      isCached = false,
      _showTodoData = true;

  TasksAsync(BuildContext context) async {
    glb.prefs = await SharedPreferences.getInstance();
    glb.userName = glb.prefs!.getString('userName')!;
    glb.CurRoleName = glb.prefs!.getString('urole')!;
    setState(() {
      taskModel = [];
      _showData = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    var tlvStr =
        "select pid,prjname,prjassigntbl.status,asid,asgnd_dt from tskmgmt.tprojecttbl,tskmgmt.prjassigntbl where pjid=pid and prjassigntbl.status=1 and prjassigntbl.status=tprojecttbl.status and usrid='$uid'";

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
          glb.showSnackBar(context, 'Error', 'No Tasks Assigned');
setState(() {
            _isLoading = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            var pid = taskMap['1'];
            var prjName = taskMap['2'];
            var status = taskMap['3'];
            var asid = taskMap['4'];
            var as_dt = taskMap['5'];
            print('as id:: $asid');

            List pidLst = glb.strToLst(pid);
            List prjNmLst = glb.strToLst(prjName);
            List asidLst = glb.strToLst(asid);
            List as_dtLst = glb.strToLst(as_dt);
            print('usrnm: $pid');
            print('asid: $asid');
            print('status:: $status');

            for (int i = 0; i < pidLst.length; i++) {
              taskModel.add(TaskModel(
                pid: pidLst.elementAt(i).toString(),
                PrjNm: prjNmLst.elementAt(i).toString(),
                asid: asidLst.elementAt(i).toString(),
                assignedDt: as_dtLst.elementAt(i).toString(),
              ));
            }

            setState(() {
              _isLoading = false;
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

  LoadTypesAsync() async {
    print("ldtsk async");
    if (glb.TaskType != null && glb.TaskType.length > 0) {
      print("Cached type :${glb.TaskType}");
      LoadPhaseAsync();
      return;
    }

    var tlvStr =
        "select tasktype from tskmgmt.taskTypes where level<=${glb.usr_lvl}";

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
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          glb.showSnackBar(context, 'Error', 'No  Data Found');
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var Phase = userMap['1'];

            print('phase:: $Phase');

            glb.TaskType = glb.strToLst2(Phase);
            print('task list : ${glb.TaskType}');
            LoadPhaseAsync();
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

  LoadPhaseAsync() async {
    taskModel = [];
    if (glb.PhaseLst != null && glb.PhaseLst.length > 0) {
      print("Cached phase :${glb.PhaseLst}");
      return;
    }

    var tlvStr = "select phasename from tskmgmt.nextphases;";

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
      print(response.body);
      if (response.statusCode == 200) {
        var res = response.body;
        if (res.contains("ErrorCode#2")) {
          glb.showSnackBar(context, 'Error', 'No Data Found');

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something  Went Wrong');
          return;
        } else {
          try {
            
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var Phase = userMap['1'];

            print('phase:: $Phase');

            glb.PhaseLst = glb.strToLst2(Phase);
            print('phase list : ${glb.PhaseLst}');
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

  var totalTaskCount = '0';
  LoadTotalTaskAsync() async {
    glb.prefs = await SharedPreferences.getInstance();

    var uid = glb.prefs!.getString('userId')!;
    var tlvStr =
        "select count(*) from tskmgmt.taskphase where ownerid='$uid' and status=1;";

    print(" task count tlv: $tlvStr");
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
          //glb.showSnackBar(context, 'Error', 'No Data Found');

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something  Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            totalTaskCount = userMap['1'];
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
  void dispose() {
    // TODO: implement dispose
    //SystemNavigator.pop();
    super.dispose();
  }

  @override
  void initState() {
    data = [
      _ChartData('David', 25),
    ];
    _tooltip = TooltipBehavior(enable: true);
    getDaysDetails();
    TasksAsync(context);
    LoadTypesAsync();
    LoadTotalTaskAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: AppColors.backColor,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Work Manager',
                                style: ralewayStyle.copyWith(
                                  fontSize: 25.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.bold,
                                )),
                            WidgetCircularAnimator(
                              size: 50,
                              innerIconsSize: 3,
                              outerIconsSize: 3,
                              innerAnimation: Curves.easeInOutBack,
                              outerAnimation: Curves.easeInOutBack,
                              innerColor: Colors.deepPurple,
                              outerColor: Colors.orangeAccent,
                              innerAnimationSeconds: 10,
                              outerAnimationSeconds: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200]),
                                child: CircleAvatar(
                                  radius: 25.0,
                                  backgroundImage: NetworkImage(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        _HeadingSection(
                          count: totalTaskCount,
                        ),
                        SizedBox(height: height * 0.03),
                        _HeadSection1(),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Container(
                          height: 50.0,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: daysModel.length,
                              itemBuilder: (context, index) {
                                return _CalendarView(model: daysModel[index]);
                              }),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        _HeadSection2(),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        _showTodoData
                            ? Container(
                                child: _TodoCreateContainer(
                                  height: height,
                                  width: width,
                                ),
                              )
                            : Container(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  itemBuilder: ((context, index) {
                                    return _TodoContainer(
                                      height: height,
                                      width: width,
                                    );
                                  }),
                                ),
                              ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        _HeadSection3(),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        _isLoading
                            ? LinearProgressIndicator()
                            : Container(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: taskModel.length,
                                  itemBuilder: ((context, index) {
                                    return _OngoingTaskWidget(
                                        height: height,
                                        width: width,
                                        model: taskModel[index]);
                                  }),
                                ),
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

List<_GetDays> daysModel = [];
var days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
void getDaysDetails() {
  daysModel = [];
  var status = 0;
  for (int i = 0; i < days.length; i++) {
    var dy = days.elementAt(i).toString();
    var date = DateTime.now();
    var curDay = DateFormat('EEEE').format(date);
    print(curDay);
    if (dy.contains(curDay)) {
      status = 1;
    } else {
      status = 0;
    }

    if (dy.length > 3) {
      dy = dy.substring(0, 3);
    }
    print(status);
    daysModel.add(_GetDays(day: dy, status: status));
  }
}

class _GetDays {
  late String day;
  late int status;
  _GetDays({
    required this.day,
    required this.status,
  });
}

class _OngoingTaskWidget extends StatelessWidget {
  const _OngoingTaskWidget({
    Key? key,
    required this.height,
    required this.width,
    required this.model,
  }) : super(key: key);

  final double width;
  final double height;
  final TaskModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              pullEmp(context);
              showLeadManagementPop(context);
              print(model.PrjNm);
              print('PRj id on clk==${model.pid} ');
              glb.Prjid = model.pid;
              glb.assid = model.asid;
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Ink(
              width: width - 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: AppColors.whiteColor,
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: 20.0,
                      child: Container(
                          width: 10.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0)),
                              color: AppColors.mainBlueColor))),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.PrjNm,
                                  style: ralewayStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: AppColors.mainBlueColor),
                                ),
                                Text(
                                  'Short Descriptions',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.more_horiz)
                          ],
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Date',
                                  style: ralewayStyle.copyWith(fontSize: 12.0),
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 15,
                                      color: AppColors.mainBlueColor,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      model.assignedDt,
                                      style:
                                          ralewayStyle.copyWith(fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              child: SfRadialGauge(
                                axes: [
                                  RadialAxis(
                                      showLabels: false,
                                      minimum: 0,
                                      maximum: 100,
                                      ranges: <GaugeRange>[
                                        GaugeRange(
                                            startValue: 0,
                                            endValue: 50,
                                            color: Colors.green),
                                        GaugeRange(
                                            startValue: 50,
                                            endValue: 100,
                                            color: Colors.orange),
                                        GaugeRange(
                                            startValue: 100,
                                            endValue: 150,
                                            color: Colors.red)
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: 90,
                                          animationDuration: 20.0,
                                          needleColor: Colors.deepOrange,
                                        )
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                            widget: Container(
                                                child: Text('75.0%',
                                                    style: TextStyle(
                                                        fontSize: 8.0,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            angle: 90,
                                            positionFactor: 0.9)
                                      ])
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.04,
        ),
      ],
    );
  }
}

List<EmpolyeeModel> lib = [];
pullEmp(BuildContext context) async {
  lib = [];
  if (glb.empMap[glb.Prjid] != null) {
    glb.uidLst = glb.empMap[glb.Prjid]!.uid;
    glb.roleLst = glb.empMap[glb.Prjid]!.role;
    glb.Empolyees = glb.empMap[glb.Prjid]!.Empolyees;
    glb.openforLst = glb.empMap[glb.Prjid]!.openFor;
    print('glb emp: ${glb.Empolyees}');
    return '';
  }
  print("tsk async");
  var tlvStr =
      "select usrname,role,openfor,tusertbl.usrid From tskmgmt.prjassigntbl,tskmgmt.uroletbl,tskmgmt.tusertbl where tusertbl.usrid=uid and tusertbl.usrid=prjassigntbl.usrid and pjid=1";

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
    print(response.body);
    if (response.statusCode == 200) {
      var res = response.body;
      if (res.contains("ErrorCode#2")) {
        print('err 2');
        glb.showSnackBar(context, 'Error', 'No  Task Found');
        return;
      } else if (res.contains("ErrorCode#8")) {
        print('err 8');
        glb.showSnackBar(context, 'Error', 'Something Went Wrong');
        return;
      } else {
        try {
          print('tri');
          Map<String, dynamic> userMap = json.decode(response.body);
          print("userMap:$userMap");

          var usrnm = userMap['1'];
          var role = userMap['2'];
          var openfor = userMap['3'];
          var uid = userMap['4'];

          List usrnmLst = glb.strToLst(usrnm);
          glb.uidLst = glb.strToLst(uid);
          glb.Empolyees = glb.strToLst2(usrnm);
          glb.roleLst = glb.strToLst(role);
          glb.openforLst = glb.strToLst(openfor);
          glb.EmpList? obj;

          obj = glb.EmpList();
          obj.Empolyees = glb.Empolyees;
          obj.role = glb.roleLst;
          obj.uid = glb.uidLst;
          obj.openFor = glb.openforLst;
          glb.empMap[glb.Prjid] = obj;
          print('obj ${obj.role}');

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

class _TeamMembers extends StatelessWidget {
  const _TeamMembers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: const CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _TodoCreateContainer extends StatelessWidget {
  const _TodoCreateContainer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.whiteColor),
          child: Stack(children: [
            Positioned(
              child: Container(
                width: 10.0,
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    color: Colors.orange),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 5.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your TODO ',
                              style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: AppColors.blueDarkColor),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Text(
                              'You can create new TODO List Here',
                              style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  color: AppColors.greyColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              glb.showSnackBar(context, 'Alert',
                                  'Feature Under Construction');
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.mainBlueColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                  ]),
            ),
          ]),
        ),
        SizedBox(
          width: width * 0.04,
        ),
      ],
    );
  }
}

class _TodoContainer extends StatelessWidget {
  const _TodoContainer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.whiteColor),
          child: Stack(children: [
            Positioned(
              child: Container(
                width: 10.0,
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    color: Colors.orange),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 5.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setup PC',
                              style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: AppColors.blueDarkColor),
                            ),
                            Text(
                              'Need to do this on Top Priority',
                              style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  color: AppColors.textColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.mainBlueColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.today_outlined,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Text(
                      'Go To Task - >',
                      style: ralewayStyle.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainBlueColor),
                    )
                  ]),
            ),
          ]),
        ),
        SizedBox(
          width: width * 0.04,
        ),
      ],
    );
  }
}

class _HeadSection3 extends StatelessWidget {
  const _HeadSection3({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Ongoing Tasks',
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Text(
          'see all',
          style: ralewayStyle.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.mainBlueColor),
        )
      ],
    );
  }
}

class _HeadSection2 extends StatelessWidget {
  const _HeadSection2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'My Todo',
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Text(
          'see all',
          style: ralewayStyle.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.mainBlueColor),
        )
      ],
    );
  }
}

class _DatesViewSection extends StatelessWidget {
  const _DatesViewSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          /* _CalendarView(date: '02'),
          _CalendarView(date: '03'),
          _CalendarView(date: '04'),
          _CalendarView(date: '05'),
          _CalendarView(date: '06'),
          _CalendarView(date: '07'),
          _CalendarView(date: '08'), */
        ],
      ),
    );
  }
}

class _HeadSection1 extends StatelessWidget {
  const _HeadSection1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Activities',
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Text(
          'Add Activity',
          style: ralewayStyle.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.mainBlueColor),
        )
      ],
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({Key? key, required this.model}) : super(key: key);

  final _GetDays model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: model.status == 0
                  ? AppColors.whiteColor
                  : AppColors.mainBlueColor),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              model.day,
              style: ralewayStyle.copyWith(
                  color: model.status == 0
                      ? AppColors.blueDarkColor
                      : AppColors.whiteColor),
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }
}

class _HeadingSection extends StatelessWidget {
  const _HeadingSection({
    Key? key,
    required this.count,
  }) : super(key: key);
  final String count;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello ${glb.userName} 👋',
            style: ralewayStyle.copyWith(
                fontSize: 16.0,
                color: AppColors.mainBlueColor,
                fontWeight: FontWeight.w900)),
        Text('Role 💼 ${glb.CurRoleName}',
            style: ralewayStyle.copyWith(
                fontSize: 12.0,
                color: AppColors.mainBlueColor,
                fontWeight: FontWeight.w900)),
        Row(
          children: [
            Icon(
              Icons.assignment,
              size: 15.0,
              color: Colors.red,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text('$count Task Pending From your Side',
                style: ralewayStyle.copyWith(
                    fontSize: 10.0,
                    color: AppColors.blueDarkColor,
                    fontWeight: FontWeight.w900)),
          ],
        )
      ],
    );
  }
}
