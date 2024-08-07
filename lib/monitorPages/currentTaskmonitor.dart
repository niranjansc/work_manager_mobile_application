import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/models/monitormodels/currenttaskModel.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:http/http.dart' as http;

class CurrentTaskMonitor extends StatefulWidget {
  const CurrentTaskMonitor({super.key});

  @override
  State<CurrentTaskMonitor> createState() => _CurrentTaskMonitorState();
}

class _CurrentTaskMonitorState extends State<CurrentTaskMonitor> {
  bool _showData = true, _isLoading = true, isCached = false;
  List<CurrentTaskModel> taskModel = [];
  LoadAllEmpAsync() async {
    setState(() {
      taskModel = [];
      _isLoading = true;
    });
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs!.getString('userId')!;
    var tlvStr =
        "select phaseid,phase,holdername,dtfrm,dtto,taskphase.phasedsc,nextphase,instname,tasktype,taskphase.holderid,role from tskmgmt.uroletbl,tskmgmt.tasktbl,tskmgmt.taskphase where tasktbl.taskid=taskphase.taskid and uroletbl.uid=taskphase.holderid and taskphase.status='1' and tasktbl.status='2' and tasktbl.ownerid='$uid' group by phaseid,phase,holdername,dtfrm,dtto,taskphase.phasedsc,nextphase,instname,tasktype,taskphase.holderid,role order by phaseid desc;";

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
          glb.showSnackBar(context, 'Error', 'No Tasks Found');
          setState(() {
            _isLoading = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          setState(() {
            _isLoading = false;
          });
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var phaseid = userMap['1'];
            var phase = userMap['2'];
            var holdername = userMap['3'];
            var dtfrm = userMap['4'];
            var dtto = userMap['5'];
            var phasedesc = userMap['6'];
            var nextPhase = userMap['7'];
            var instname = userMap['8'];
            var taskType = userMap['9'];
            var holderid = userMap['10'];
            var holderrole = userMap['11'];

            List phaseIDLst = glb.strToLst(phaseid);
            List phaseNameLst = glb.strToLst(phase);
            List holderNameLst = glb.strToLst(holdername);
            List dtFromLst = glb.strToLst(dtfrm);
            List dtToLst = glb.strToLst(dtto);
            List phaseDescLst = glb.strToLst(phasedesc);
            List instNameLst = glb.strToLst(instname);
            List taskTypeLst = glb.strToLst(taskType);
            List holderIDLst = glb.strToLst(holderid);
            List holderroleLst = glb.strToLst(holderrole);

            for (int i = 0; i < phaseIDLst.length; i++) {
              var phaseid = phaseIDLst.elementAt(i).toString();
              var phaseName = phaseNameLst.elementAt(i).toString();
              var holderName = holderNameLst.elementAt(i).toString();
              var dtFrom = dtFromLst.elementAt(i).toString();
              var dtTO = dtToLst.elementAt(i).toString();
              var phaseDesc = phaseDescLst.elementAt(i).toString();
              var instName = instNameLst.elementAt(i).toString();
              var taskType = taskTypeLst.elementAt(i).toString();
              var holderID = holderIDLst.elementAt(i).toString();
              if (phaseDesc.length > 15) {
                phaseDesc = phaseDesc.substring(0, 15);
              }
              var holderRole = holderroleLst.elementAt(i).toString();
              taskModel.add(CurrentTaskModel(
                  phaseid: phaseid,
                  phaseName: phaseName,
                  holderName: holderName,
                  dtFrom: dtFrom,
                  dtTO: dtTO,
                  phaseDesc: phaseDesc,
                  instName: instName,
                  taskType: taskType,
                  holderID: holderID,
                  holderRole: holderRole));
            }

            setState(() {
              _isLoading = false;
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
    LoadAllEmpAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: _MainHeaders(),
      ),
      backgroundColor: AppColors.backColor,
      body: RefreshIndicator(
        onRefresh: () async {
          LoadAllEmpAsync();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 2.0,
                ),
                _HeadingSection(),
                SizedBox(
                  height: height * 0.03,
                ),
                _isLoading
                    ? const LinearProgressIndicator()
                    : Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, _) =>
                                SizedBox(height: height * 0.02),
                            itemCount: taskModel.length,
                            itemBuilder: (context, index) {
                              return _CurrentTaskCard(
                                  width: width,
                                  height: height,
                                  curmodel: taskModel[index]);
                            }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentTaskCard extends StatelessWidget {
  const _CurrentTaskCard({
    Key? key,
    required this.width,
    required this.height,
    required this.curmodel,
  }) : super(key: key);

  final double width;
  final double height;
  final CurrentTaskModel curmodel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      TextWidget(
                          title: curmodel.instName,
                          fontsize: 14,
                          color: AppColors.blueDarkColor),
                    ],
                  ),
                  Icon(Icons.more_horiz)
                ],
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stay_current_portrait),
                      SizedBox(
                        width: 1,
                      ),
                      Text(
                        'Phase Name : ${curmodel.phaseName}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          TextWidget(
                              title: "From: ${curmodel.dtFrom}",
                              fontsize: 15,
                              color: AppColors.textColor),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          TextWidget(
                              title: "To: ${curmodel.dtTO}",
                              fontsize: 15,
                              color: AppColors.textColor),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.blue,
                        size: 15,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      TextWidget(
                        title: 'Holder Name : ${curmodel.holderName}',
                        fontsize: 12,
                        color: AppColors.blueDarkColor,
                      )
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.file_open,
                        size: 15,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      TextWidget(
                          title: 'Role : ${curmodel.holderRole}',
                          fontsize: 12,
                          color: AppColors.textColor),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.file_open,
                        color: Colors.orange,
                        size: 15,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      TextWidget(
                          title: 'Status : ',
                          fontsize: 12,
                          color: AppColors.textColor),
                      TextWidget(
                          title: 'Active', fontsize: 12, color: Colors.green),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.file_open,
                        size: 15,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      TextWidget(
                          title: 'Description : ${curmodel.phaseDesc}',
                          fontsize: 10,
                          color: AppColors.textColor),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                ],
              ),
            ],
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
        Text('On Going Tasks',
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
                color: Colors.purple,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.task,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
        ),
      ],
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
            Text('Monitor All Your Tasks Here',
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
