import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/models/employeemodel.dart';
import 'package:work_manager/models/monitormodels/empfiltermodel.dart';
import 'package:work_manager/models/monitormodels/taskmodel.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:http/http.dart' as http;

class TaskMonitorPage extends StatefulWidget {
  const TaskMonitorPage({super.key});

  @override
  State<TaskMonitorPage> createState() => _TaskMonitorPageState();
}

class _TaskMonitorPageState extends State<TaskMonitorPage> {
  bool _showData = true;
  List<TaskMonitorModel> taskModel = [];

  AsyncTaskMonitor() async {
    setState(() {
      _showData = true;
      taskModel = [];
    });

    //select usrname,instname,phase,isusing,epochfrm,epochto,phasedsc,tasktbl.taskid,phaseid from tskmgmt.tusertbl,tskmgmt.tasktbl,tskmgmt.taskphase where  taskphase.taskid=tasktbl.taskid and taskphase.ownerid=tasktbl.ownerid and tasktbl.holderid=tusertbl.usrid and taskphase.ownerid!=tasktbl.holderid and  tusertbl.usrid=2
    glb.prefs = await SharedPreferences.getInstance();
    glb.userID = glb.prefs!.getString('userId')!;
    var uid = glb.userID;
    var userRole = glb.prefs!.getString('urole')!;
    var filter = '';
    if (glb.roleFilter == 'Super Connector') {
      filter =
          "and tasktbl.sconnectorid=tusertbl.usrid and tasktbl.sconnectorid=$uid";
    } else if (glb.roleFilter == 'Connector') {
      filter =
          "and tasktbl.connectorid=tusertbl.usrid and tasktbl.connectorid = $uid";
    } else if (glb.roleFilter == 'BDM') {
      filter = "and tasktbl.bdmid=tusertbl.usrid and tasktbl.bdmid = $uid";
    } else {
      filter =
          "and tasktbl.holderid=tusertbl.usrid and taskphase.ownerid!=tasktbl.holderid";
    }
    var tlvStr =
        "select ownername,instname,phase,isusing,epochfrm,epochto,taskphase.phasedsc,tasktbl.taskid,phaseid from tskmgmt.tusertbl,tskmgmt.tasktbl,tskmgmt.taskphase where  taskphase.taskid=tasktbl.taskid  $filter and tusertbl.usrid=$uid and taskphase.status='1'";
    print('queryName::$tlvStr');
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
          glb.showSnackBar(context, 'Error', 'No Tasks Found');
          setState(() {
            _showData = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("taskMap:$userMap");

            var usrNm = userMap['1'];
            var instName = userMap['2'];
            var phase = userMap['3'];

            var isUsing = userMap['4'];
            var frmepoch = userMap['5'];
            var toepoch = userMap['6'];
            var phasedesc = userMap['7'];
            var taskid = userMap['8'];
            var phasid = userMap['9'];

            List instNmLst = glb.strToLst(instName);
            List usrNmLst = glb.strToLst(usrNm);
            List PhaseLst = glb.strToLst(phase);
            List isUsingLst = glb.strToLst(isUsing);
            List FrmDtLst = glb.strToLst(frmepoch);
            List FrmTimLst = glb.strToLst(toepoch);
            List PhasedescLst = glb.strToLst(phasedesc);
            List taskidLst = glb.strToLst(taskid);
            List phaseidLst = glb.strToLst(phasid);

            for (int i = 0; i < usrNmLst.length; i++) {
              var fromEpoch = FrmDtLst.elementAt(i);
              var toEpoch = FrmTimLst.elementAt(i);
              var frdt = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(fromEpoch) * 1000);
              var todt = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(toEpoch) * 1000);
              print('display dt::$frdt');
              print('display todt:: $todt');
              var phdsc = PhasedescLst.elementAt(i);
              print(phdsc);
              if (phdsc.toString().isEmpty) {
                continue;
              }
              taskModel.add(TaskMonitorModel(
                  userName: usrNmLst.elementAt(i),
                  instName: instNmLst.elementAt(i),
                  phaseName: PhaseLst.elementAt(i),
                  isUsing: isUsingLst.elementAt(i),
                  fromEpoch: frdt.toString(),
                  toEpoch: todt.toString(),
                  phaseDesc: phdsc,
                  taskID: taskidLst.elementAt(i),
                  phaseID: phaseidLst.elementAt(i)));
            }

            setState(() {
              taskModelCache = List.from(taskModel);
              _showData = false;
              pullEmployees(context);
            });

            //Navigator.pop(context);
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
  }

  @override
  void initState() {
    AsyncTaskMonitor();
    super.initState();
  }

  TextEditingController searchController = TextEditingController();
  List<TaskMonitorModel> taskModelCache = [];
  void filterSearchResults(String query) {
    List<TaskMonitorModel> dummySearchList = [];
    dummySearchList.clear();
    dummySearchList.addAll(taskModelCache);
    if (query.isNotEmpty) {
      List<TaskMonitorModel> dummyListData = [];

      final suggestions = dummySearchList.where((element) {
        final nameTitle = element.instName.toLowerCase();
        final input = query.toLowerCase();
        print(nameTitle);
        print(input);
        return nameTitle.contains(input);
      }).toList();

      setState(() {
        taskModel.clear();
        taskModel = suggestions;
        //taskModel.addAll(dummyListData);
      });
      return;
    } else {
      print('return to normal $taskModelCache');
      setState(() {
        taskModel.clear();
        taskModel.addAll(taskModelCache);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("vvvvv");
    print("filter = ${glb.roleFilter}");
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: _MainHeaders()),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50.0,
                  width: width - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    onChanged: ((value) {
                      print('Value::$value');
                      filterSearchResults(value);
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
                        hintText: 'Search Institute Here',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showFilter(context, width, height);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.filter_list),
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
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.location_history),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.03,
            ),
            _showData
                ? Expanded(
                    child: RefreshIndicator(
                    onRefresh: () async {
                      AsyncTaskMonitor();
                    },
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                      enabled: _showData,
                      child: ListView.separated(
                          itemCount: 10,
                          separatorBuilder: (context, _) =>
                              SizedBox(height: height * 0.02),
                          itemBuilder: ((context, index) {
                            return const ShimmerCardLayout();
                          })),
                    ),
                  ))
                : Expanded(
                    child: RefreshIndicator(
                    onRefresh: () async {
                      AsyncTaskMonitor();
                    },
                    child: ListView.separated(
                        itemCount: taskModel.length,
                        separatorBuilder: (context, _) =>
                            SizedBox(height: height * 0.02),
                        itemBuilder: ((context, index) {
                          return MonitorTaskCard(
                              width: width,
                              height: height,
                              model: taskModel[index]);
                        })),
                  ))
          ],
        ),
      )),
    );
  }
}

class ShimmerCardLayout extends StatelessWidget {
  const ShimmerCardLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48.0,
          height: 48.0,
          color: Colors.white,
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
                height: 8.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Container(
                width: double.infinity,
                height: 8.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Container(
                width: 40.0,
                height: 8.0,
                color: Colors.white,
              ),
            ],
          ),
        )
      ]),
    );
  }
}

TextEditingController searchController = TextEditingController();
void showFilter(BuildContext context, double width, double height) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  return Container(
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
        empFilter.isNotEmpty
            ? Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, _) => SizedBox(height: 5),
                  itemCount: empFilter.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _EmpCard(model: empFilter[index]);
                  },
                ),
              )
            : const Text('No Employees Found'),
      ],
    ),
  );
}

class _EmpCard extends StatelessWidget {
  const _EmpCard({
    Key? key,
    required this.model,
  }) : super(key: key);

  final EmpFilter model;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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

List<EmpolyeeModel> lib = [];
List<EmpFilter> empFilter = [];
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
                EmpID: uid, EmpName: name, EmpRole: role, EmpOpenFor: openFor));
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

class MonitorTaskCard extends StatelessWidget {
  const MonitorTaskCard({
    Key? key,
    required this.width,
    required this.height,
    required this.model,
  }) : super(key: key);
  final double width;
  final double height;
  final TaskMonitorModel model;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          glb.TaskId = model.taskID;
          glb.PhaseId = model.phaseID;
          var instName = model.instName;
          var taskName = model.userName;
          glb.curTaskName = model.phaseName;
          showAlert(context, instName, taskName);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Ink(
            width: width - 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: AppColors.whiteColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey[200]),
                        child: CircleAvatar(
                          radius: 25.0,
                          backgroundImage: NetworkImage(
                              'https://www.shutterstock.com/image-photo/tasks-word-on-wooden-cubes-260nw-1904598853.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_pin_circle_outlined,
                                color: Colors.green,
                                size: 15.0,
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              Text(model.userName,
                                  style: ralewayStyle.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blueDarkColor)),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            children: [
                              Icon(
                                Icons.balcony,
                                color: Colors.blue,
                                size: 15.0,
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              Text(model.instName,
                                  style: ralewayStyle.copyWith(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blueDarkColor)),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
                          Text("Phase: ${model.phaseName}"),
                          SizedBox(height: height * 0.02),
                          Text("Desc: ${model.phaseDesc}"),
                          SizedBox(height: height * 0.01),
                          Container(
                            height: 0.2,
                            width: height * 0.3,
                            color: Colors.grey,
                            margin:
                                const EdgeInsets.only(top: 10.0, right: 10.0),
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: Colors.blue,
                                size: 15.0,
                              ),
                              Text('From :',
                                  style: ralewayStyle.copyWith(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              Text(model.fromEpoch,
                                  style: ralewayStyle.copyWith(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: Colors.red,
                                size: 15.0,
                              ),
                              Text('To : ',
                                  style: ralewayStyle.copyWith(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              Text(model.toEpoch,
                                  style: ralewayStyle.copyWith(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ],
                          ),
                          Container(
                            height: 0.2,
                            width: height * 0.3,
                            color: Colors.grey,
                            margin:
                                const EdgeInsets.only(top: 10.0, right: 10.0),
                          ),
                          SizedBox(height: height * 0.02),
                          Visibility(
                            visible: false,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_pin_circle_outlined,
                                  color: Colors.blue,
                                  size: 15.0,
                                ),
                                Text(' 4',
                                    style: ralewayStyle.copyWith(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                SizedBox(
                                  width: width * 0.01,
                                ),
                                Text('Employees Assigned',
                                    style: ralewayStyle.copyWith(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

void showAlert(BuildContext context, String InstName, String TaskName) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                  title: 'Task Monitor',
                  fontsize: 16,
                  color: AppColors.blueDarkColor),
              SizedBox(
                height: 5.0,
              ),
              TextWidget(
                  title: 'Inst Name : $InstName',
                  fontsize: 10,
                  color: AppColors.blueDarkColor),
              SizedBox(
                height: 5.0,
              ),
              TextWidget(
                  title: 'Creator : $TaskName',
                  fontsize: 9,
                  color: AppColors.blueDarkColor),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(1, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.emoji_emotions,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  TextWidget(
                      title: 'Want would you like to do',
                      fontsize: 12,
                      color: AppColors.textColor),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: AppColors.blueDarkColor))
                ],
              ),
            ],
          ),
          content: Container(
            height: MediaQuery.of(ctx).size.height / 5,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      //Navigator.pop(context);
                      Navigator.pushNamed(ctx, NextPhaseRoute);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.green,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.update,
                              color: AppColors.whiteColor,
                            ),
                            Text(
                              'Pass Task To Next Level',
                              style: ralewayStyle.copyWith(
                                  color: AppColors.whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      UpdateStatusPop(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.manage_history_rounded,
                              color: Colors.white,
                            ),
                            Text(
                              'Mark Status',
                              style: ralewayStyle.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: AppColors.whiteColor,
                            ),
                            Text(
                              'Delete Task',
                              style: ralewayStyle.copyWith(
                                  color: AppColors.whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

List<String> rate = <String>['Neutral', 'Positive', 'Negative'];
String rateval = '';

UpdateStatusPop(BuildContext context) {
  TextEditingController typeController = TextEditingController();
  PosVis = false;
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              title: TextWidget(
                  title: 'Update Status',
                  fontsize: 16,
                  color: AppColors.blueDarkColor),
              content: Container(
                height: 180,
                child: Column(
                  children: [
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: AppColors.whiteColor,
                      ),
                      child: TextField(
                        controller: typeController,
                        enableInteractiveSelection: false,
                        focusNode: glb.AlwaysDisabledFocusNode(),
                        style: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor,
                            fontSize: 12.0),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.merge_type),
                            ),
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (String value) {
                                typeController.text = value;
                                setState(() {
                                  rateval = value;
                                  if (rateval == 'Positive') {
                                    PosVis = true;
                                  } else if (rateval == 'Negative') {
                                    Rating = '-1';
                                    PosVis = false;
                                  } else {
                                    Rating = '0';
                                    print(Rating);
                                    PosVis = false;
                                  }
                                });
                                print("selected role type: $value");
                              },
                              itemBuilder: (BuildContext context) {
                                return rate
                                    .map<PopupMenuItem<String>>((String value) {
                                  return PopupMenuItem(
                                      child: Text(value), value: value);
                                }).toList();
                              },
                            ),
                            contentPadding: const EdgeInsets.only(top: 16.0),
                            hintText: 'Select Type',
                            hintStyle: ralewayStyle.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.blueDarkColor.withOpacity(0.5),
                                fontSize: 12.0)),
                      ),
                    ),
                    Visibility(
                      visible: PosVis,
                      child: RatingBar.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return Icon(
                            Icons.star,
                            size: 1,
                            color: Colors.amber,
                          );
                        },
                        onRatingUpdate: (double value) {
                          if (rateval == 'Positive') {
                            Rating = '+${value.toString()}';
                            print(Rating);
                          } else if (rateval == 'negative') {
                            Rating = '-1';
                            print(Rating);
                          } else if (rateval == 'neutral') {
                            Rating = '0';
                            print(Rating);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: () {
                            print(Rating);
                            UpdateTaskStatusAsync(context);
                            Navigator.pop(context);
                          },
                          child: ButtonWidget(title: 'Submit')),
                    )
                  ],
                ),
              ),
            );
          },
        );
      });
}

bool PosVis = false;
String Rating = '0';

UpdateTaskStatusAsync(BuildContext context) async {
  print("Insert country async");
  var tlvStr =
      "update tskmgmt.tasktbl set positive=${Rating} where taskid=${glb.TaskId}";

  print(" login tlv: $tlvStr");
  String url = glb.endPoint;

  final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

  try {
    print('try');
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
        glb.showSnackBar(context, 'Success', 'Contact Your Admin');

        return;
      } else if (res.contains("ErrorCode#8")) {
        glb.showSnackBar(context, 'Error', 'Something Went Wrong');
        return;
      } else if (res.contains("ErrorCode#0")) {
        glb.showSnackBar(context, 'Success', 'Updated Successfully');
        return;
      }
    } else if (response.statusCode == 0) {
      print('0');
    }
  } catch (e) {
    glb.handleErrors(e, context);
  }

  return "Success";
}
//

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
        Text('Task Monitor',
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
                color: AppColors.mainBlueColor,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.task_alt_outlined,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
