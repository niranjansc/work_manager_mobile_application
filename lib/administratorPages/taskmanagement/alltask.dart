import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/models/alltaskmodel.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;
import 'package:work_manager/globalPages/workglb.dart' as glb;

var taskStatus = '1';
var phasevalSts = '1';
String dropdownValue = tasks.first;
String phaseval = glb.PhaseLst.first;
String rateval = rate.first;
String Filterval = Filter.first;
bool _showData = true, _isLoading = true, isCached = false;

List<String> rate = <String>['Neutral', 'Positive', 'Negative'];
List<String> Filter = <String>[
  'Open',
  'In progress',
  'Closed',
  'Rejected',
];

List<String> tasks = <String>[
  'All',
  'Following',
  'Depolyment',
  'Demo',
  'Post demo',
  'Renewal',
  'Visit',
  'Reopen',
  'Not intrested',
];

class AllTaskPage extends StatefulWidget {
  const AllTaskPage({super.key});

  @override
  State<AllTaskPage> createState() => _AllTaskPageState();
}

class _AllTaskPageState extends State<AllTaskPage> {
  List<AllTaskModel> taskModel = [];

  AsyncAllTask() async {
    setState(() {
      _showData = true;
      taskModel = [];
    });

    glb.prefs = await SharedPreferences.getInstance();
    glb.userID = glb.prefs!.getString('userId')!;
    var filter = "and tasktbl.status=${taskStatus}";

    if (Filterval == 'In progress') {
      // get phaseval
      filter = "and tasktbl.status=2 and phase='${glb.phaseval_filter}'";
    }
    var tlvStr =
        "select usrname,instname,phase,isusing,epochfrm,epochto,taskphase.phasedsc,tasktbl.taskid,phaseid from tskmgmt.tusertbl,tskmgmt.tasktbl,tskmgmt.taskphase where cityid=${glb.CityID} and tasktbl.ownerid='${glb.userID}' and taskphase.taskid=tasktbl.taskid  and taskphase.status=1 $filter and (tusertbl.usrid=${glb.userID} or (tusertbl.usrid='-1' and cityid=${glb.CityID})) and tasktbl.ownerid=tusertbl.usrid; ";

    print(" all Task tlv: $tlvStr");
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

            print(taskid);
            print(phasedesc);
            List instNmLst = glb.strToLst(instName);
            List usrNmLst = glb.strToLst(usrNm);
            List PhaseLst = glb.strToLst(phase);
            // List countryLst = glb.strToLst(country);
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
              print('displat dt::$frdt');
              print('display todt:: $todt');
              taskModel.add(AllTaskModel(
                phaseid: phaseidLst.elementAt(i),
                taskid: taskidLst.elementAt(i),
                PersonName: usrNmLst.elementAt(i),
                InstName: instNmLst.elementAt(i),
                FrmDt: frdt.toString(),
                todt: todt.toString(),
                desc: PhasedescLst.elementAt(i),
                phase: PhaseLst.elementAt(i),
              ));
            }

            setState(() {
              _isLoading = false;
              _showData = false;
              isCached = true;
              // Navigator.pop(context);
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

    return "Success";
  }

  @override
  void initState() {
    setState(() {
      filterController.text = Filter.first;
      // glb.showLoaderDialog(context, true);
    });
    AsyncAllTask();

    super.initState();
  }

  TextEditingController filterController = TextEditingController();
  TextEditingController phaseController = TextEditingController();
  bool phaseFiltervisi = false;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: _MainHeaders(),
      ),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                    width: 160.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: filterController,
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
                            icon: Icon(Icons.control_point),
                          ),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              filterController.text = value;

                              setState(() {
                                Filterval = value;

                                print(Filterval);
                                print(Filter.indexOf(Filterval));
                                print('Dv: $Filterval');
                                if (Filter.indexOf(Filterval) == 0) {
                                  taskStatus = '1';
                                } else if (Filter.indexOf(Filterval) == 1) {
                                  taskStatus = '2';
                                } else if (Filter.indexOf(Filterval) == 2) {
                                  taskStatus = '3';
                                } else if (Filter.indexOf(Filterval) == 3) {
                                  taskStatus = '4';
                                }
                                if (taskStatus == '2') {
                                  phaseController.text = phaseval;
                                  phaseFiltervisi = true;
                                } else {
                                  phaseFiltervisi = false;
                                }
                              });
                              AsyncAllTask();
                              print("selected role type: $value");
                            },
                            itemBuilder: (BuildContext context) {
                              return Filter.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Filter',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                  Visibility(
                    visible: phaseFiltervisi,
                    child: Container(
                      height: 50.0,
                      width: 160.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: AppColors.whiteColor,
                      ),
                      child: TextField(
                        controller: phaseController,
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
                                phaseController.text = value;
                                setState(() {
                                  phaseval = value;
                                  print('Dv Phase: $phaseval');
                                  glb.phaseval_filter = phaseval;
                                  for (int i = 0;
                                      i < glb.PhaseLst.length;
                                      i++) {
                                    if (glb.PhaseLst.indexOf(phaseval) == i) {
                                      print('i:$i');
                                      phasevalSts = (i + 1).toString();
                                      print('phase val sts $phasevalSts');
                                    }
                                  }
                                });
                                AsyncAllTask();
                                print("selected phase type: $value");
                              },
                              itemBuilder: (BuildContext context) {
                                return glb.PhaseLst.map<PopupMenuItem<String>>(
                                    (String value) {
                                  return PopupMenuItem(
                                      child: Text(value), value: value);
                                }).toList();
                              },
                            ),
                            contentPadding: const EdgeInsets.only(top: 16.0),
                            hintText: 'Phase',
                            hintStyle: ralewayStyle.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.blueDarkColor.withOpacity(0.5),
                                fontSize: 12.0)),
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
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                        enabled: _showData,
                        child: ListView.separated(
                          separatorBuilder: (context, _) =>
                              SizedBox(height: height * 0.02),
                          itemBuilder: (context, index) {
                            return const ShimmerCardLayout();
                          },
                          itemCount: 10,
                        ),
                      ),
                    )
                  : Expanded(
                      child: RefreshIndicator(
                      onRefresh: () async {
                        taskModel = [];
                        AsyncAllTask();
                      },
                      child: ListView.separated(
                        separatorBuilder: (context, _) =>
                            SizedBox(height: height * 0.02),
                        itemBuilder: (context, index) {
                          return AllTaskCard(
                              width: width,
                              height: height,
                              model: taskModel[index]);
                        },
                        itemCount: taskModel.length,
                      ),
                    )),
            ],
          ),
        ),
      ),
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

class AllTaskCard extends StatelessWidget {
  const AllTaskCard({
    Key? key,
    required this.width,
    required this.height,
    required this.model,
  }) : super(key: key);

  final double width;
  final double height;
  final AllTaskModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              glb.TaskId = model.taskid;
              glb.PhaseId = model.phaseid;
              var instName = model.InstName;
              var taskName = model.PersonName;
              glb.curTaskName = model.phase;
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
                                shape: BoxShape.circle,
                                color: Colors.grey[200]),
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
                                  Text(model.InstName,
                                      style: ralewayStyle.copyWith(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blueDarkColor)),
                                ],
                              ),
                              SizedBox(height: height * 0.01),
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
                                  Text(model.PersonName,
                                      style: ralewayStyle.copyWith(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blueDarkColor)),
                                ],
                              ),
                              Container(
                                height: 0.2,
                                width: height * 0.3,
                                color: Colors.grey,
                                margin: const EdgeInsets.only(
                                    top: 10.0, right: 10.0),
                              ),
                              SizedBox(height: height * 0.02),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Colors.orange,
                                    size: 15.0,
                                  ),
                                  SizedBox(
                                    width: width * 0.01,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                          '${glb.CntryNM}/${glb.StateNM}/${glb.DistNM}/${glb.TalukNM}/${glb.CityNM}',
                                          style: ralewayStyle.copyWith(
                                              overflow: TextOverflow.visible,
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.blueDarkColor)),
                                    ],
                                  ),
                                ],
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
                                  Text(model.FrmDt,
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
                                  Text(model.todt,
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
                                margin: const EdgeInsets.only(
                                    top: 10.0, right: 10.0),
                              ),
                              SizedBox(height: height * 0.02),
                              Row(
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
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
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
        Text('Task Management',
            style: ralewayStyle.copyWith(
              fontSize: 18.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AddTaskRoute);
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Ink(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Add New Task +',
                    style: ralewayStyle.copyWith(
                      fontSize: 12.0,
                      color: AppColors.mainBlueColor,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showAlert(BuildContext context, String InstName, String TaskName) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                  title: 'Task Management',
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
            height: MediaQuery.of(context).size.height / 5,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      //Navigator.pop(context);
                      print('Next Phase');
                      Navigator.pushNamed(context, NextPhaseRoute);
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