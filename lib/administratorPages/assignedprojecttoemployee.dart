// ignore_for_file: avoid_print, non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/models/assignedempmodel.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AssignedEmployeeProjectPage extends StatefulWidget {
  const AssignedEmployeeProjectPage({super.key});

  @override
  State<AssignedEmployeeProjectPage> createState() =>
      _AssignedEmployeeProjectPageState();
}

class _AssignedEmployeeProjectPageState
    extends State<AssignedEmployeeProjectPage> {
  bool _isLoading = true;
  List<AssignedEmpModel> assignModel = [];
  AsyncEmpDetails() async {
    setState(() {
      _isLoading = true;
      assignModel = [];
    });

    var tlvStr =
        "select tusertbl.usrid,usrname,role,created_at from tskmgmt.uroletbl,tskmgmt.tusertbl,tskmgmt.prjassigntbl,tskmgmt.tprojecttbl where uroletbl.uid=tusertbl.usrid and  prjassigntbl.pjid=tprojecttbl.pid and tusertbl.usrid=prjassigntbl.usrid and pjid='$prjID'  order by usrname;";

    print(" assigned project tlv: $tlvStr");
    String url = endPoint;

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
          showSnackBar(context, 'Error', 'No Employee Assigned');
          setState(() {
            _isLoading = false;
            Navigator.pop(context);
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          showSnackBar(context, 'Error', 'Something Went Wrong');

          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> taskMap = json.decode(response.body);
            print("taskMap:$taskMap");

            var uid = taskMap['1'];
            var uname = taskMap['2'];
            var role = taskMap['3'];
            var createdAt = taskMap['4'];

            List uidLst = strToLst(uid);
            List uNameLst = strToLst(uname);
            List roleLst = strToLst(role);
            List createdAtLst = strToLst(createdAt);

            for (int i = 0; i < uidLst.length; i++) {
              var empID = uidLst.elementAt(i).toString();
              var empName = uNameLst.elementAt(i).toString();
              var empRole = roleLst.elementAt(i).toString();
              var dt = createdAtLst.elementAt(i).toString();

              assignModel.add(AssignedEmpModel(
                  empID: empID,
                  empName: empName,
                  empRole: empRole,
                  createdDT: dt));
            }

            setState(() {
              _isLoading = false;
            });

            //   Navigator.pop(context);
          } catch (e) {
            print(e);
            //     Navigator.pop(context);
            return "Failed";
          }
        }
      }
    } catch (e) {
      // Navigator.pop(context);
      handleErrors(e, context);
    }

    return "Success";
  }

  @override
  void initState() {
    AsyncEmpDetails();
    super.initState();
  }

  var items = [
    'Connector',
    'Router installer',
    'Telecaller',
    'BDM',
    'Testing',
    'Support',
    'Dev',
    'Franchise',
    'State head',
    'National head',
    'Director'
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const _MainHeaders(),
      ),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: height * 0.02,
          ),
          _isLoading
              ? const LinearProgressIndicator()
              : Expanded(
                  child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                      separatorBuilder: (context, _) =>
                          SizedBox(height: height * 0.02),
                      itemCount: assignModel.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.purple.withOpacity(0.1)),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextWidget(
                                        title: prjName,
                                        fontsize: 10,
                                        color: AppColors.textColor),
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.shield_moon_outlined,
                                            size: 15),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        TextWidget(
                                            title:
                                                "Created At - ${assignModel[index].createdDT}",
                                            fontsize: 10,
                                            color: AppColors.greyColor)
                                      ],
                                    ),
                                    const Icon(Icons.more_horiz)
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Row(
                                  children: [
                                    WidgetCircularAnimator(
                                      size: 40,
                                      innerIconsSize: 3,
                                      outerIconsSize: 3,
                                      innerAnimation: Curves.easeInOutBack,
                                      outerAnimation: Curves.easeInOutBack,
                                      innerColor: Colors.orange,
                                      outerColor: Colors.deepPurple,
                                      innerAnimationSeconds: 10,
                                      outerAnimationSeconds: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[200]),
                                        child: CircleAvatar(
                                          radius: 25.0,
                                          backgroundImage: NetworkImage(
                                              'https://www.shutterstock.com/image-photo/new-project-word-on-notepad-260nw-293529491.jpg'),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.02,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                            title: assignModel[index].empName,
                                            fontsize: 14,
                                            color: AppColors.blueDarkColor),
                                        SizedBox(
                                          height: height * 0.01,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.deepOrange
                                                  .withOpacity(0.2)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextWidget(
                                                title:
                                                    'Role : ${assignModel[index].empRole}',
                                                fontsize: 10,
                                                color: AppColors.blueDarkColor),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ))
        ],
      )),
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
        Text('Projects Assigned',
            style: ralewayStyle.copyWith(
              fontSize: 25.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.remove_red_eye,
              color: AppColors.whiteColor,
            ),
          ),
        )
      ],
    );
  }
}
