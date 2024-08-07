import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_manager/administratorPages/employeemanagement.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/models/allPorojectmodel.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;

class AllProjectsPage extends StatefulWidget {
  const AllProjectsPage({super.key});

  @override
  State<AllProjectsPage> createState() => _AllProjectsPageState();
}

class _AllProjectsPageState extends State<AllProjectsPage> {
  List<AllProjectModel> projectModel = [];
  bool _showData = true, _isLoading = true, isCached = false;
  AsyncProjects() async {
    setState(() {
      _showData = true;
      projectModel = [];
    });
    //select pid,prjname,status from tskmgmt.tprojecttbl
    var tlvStr = "select pid,prjname,status from tskmgmt.tprojecttbl";

    print(" project tlv: $tlvStr");
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
          showSnackBar(context, 'Error', 'No Projects Found');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
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

            var pid = taskMap['1'];
            var pname = taskMap['2'];
            var status = taskMap['3'];

            List pidLst = strToLst(pid);
            List pNameLst = strToLst(pname);
            List statusLst = strToLst(status);

            for (int i = 0; i < pidLst.length; i++) {
              projectModel.add(AllProjectModel(
                  projectId: pidLst.elementAt(i).toString(),
                  projectName: pNameLst.elementAt(i).toString(),
                  status: statusLst.elementAt(i).toString()));
            }

            setState(() {
              _isLoading = false;
              _showData = false;
              isCached = true;
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
    super.initState();
    //showLoaderDialog(context, true);
    AsyncProjects();
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.03,
                ),
                _showData
                    ? Expanded(
                        child: Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                        enabled: _showData,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            AsyncProjects();
                          },
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
                          AsyncProjects();
                        },
                        child: ListView.separated(
                            itemCount: projectModel.length,
                            separatorBuilder: (context, _) =>
                                SizedBox(height: height * 0.02),
                            itemBuilder: ((context, index) {
                              return AllProjectsCard(
                                  width: width,
                                  height: height,
                                  model: projectModel[index]);
                            })),
                      ))
              ],
            ),
          ),
        ));
  }
}

class AllProjectsCard extends StatelessWidget {
  const AllProjectsCard({
    Key? key,
    required this.width,
    required this.height,
    required this.model,
  }) : super(key: key);

  final double width;
  final double height;
  final AllProjectModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (assignProject) {
                prjID = model.projectId;
                prjName = model.projectName;
                showAlert(context);
              } else {
                prjID = model.projectId;
                prjName = model.projectName;
                showAssignAlert(context);
              }
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
                                  'https://cdn.xxl.thumbs.canstockphoto.com/project-word-with-cogs-in-background-isolated-on-white-drawings_csp5874299.jpg'),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                  title: model.projectName,
                                  fontsize: 12.0,
                                  color: AppColors.blueDarkColor),
                              /*   SizedBox(height: height * 0.01),
                              Row(children: [
                                _ProfilePics(),
                                _ProfilePics(),
                                _ProfilePics(),
                                _ProfilePics(),
                              ]),
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
                             */
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

void showAssignAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                  title: 'Project Name : $prjName',
                  fontsize: 12,
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
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 9,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, ProjectAssignedEmployeeRoute);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.deepPurple,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.task,
                              color: AppColors.whiteColor,
                            ),
                            Text(
                              'View Assigned Employees',
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
                      //Need To check if project is assigned to anyone if not only then delete project
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
                              'Delete Project',
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

void showAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                  title: 'Employee Name : ${EmpName}',
                  fontsize: 16,
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
                      showLoaderDialog(context, true);
                      AsyncAssignProject(context);
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
                              Icons.task,
                              color: AppColors.whiteColor,
                            ),
                            Text(
                              'Assign Project',
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
              ],
            ),
          ),
        );
      });
}

AsyncAssignProject(BuildContext context) async {
  var tlvStr =
      "insert into tskmgmt.prjassigntbl(pjid,usrid,status) values(${prjID},${EmpID},'1');";

  print(" prj Assign tlv: $tlvStr");
  String url = endPoint;

  final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

  try {
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dict));
    print("REsponse::${response.body}");

    if (response.statusCode == 200 || response.statusCode == 400) {
      // print('response code:${res}');
      if (response.body.contains("ErrorCode#0")) {
        showSnackBar(context, 'Error', 'Project Assigned Successfully');
        assignProject = false;
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      } else if (response.body.contains("ErrororCode#8") ||
          response.body.contains("ErrorCode#8")) {
        showSnackBar(context, 'Error', 'Something went wrong');
        Navigator.pop(context);
        assignProject = false;
        return;
      } else {}
    }
  } catch (e) {
    handleErrors(e, context);
  }

  return "Success";
}

class _ProfilePics extends StatelessWidget {
  const _ProfilePics({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
      child: CircleAvatar(
        radius: 25.0,
        backgroundImage: NetworkImage(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
        backgroundColor: Colors.transparent,
      ),
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
        Text('Projects',
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
                    Icons.file_present_outlined,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
        ),
      ],
    );
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
