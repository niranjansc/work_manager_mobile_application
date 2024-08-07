import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/edittextWidget.dart';
import 'package:work_manager/dynamicPages/mobile_edittext.dart';
import 'package:work_manager/dynamicPages/passwordWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/cacheglb.dart';
import 'package:work_manager/models/employeemodel.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  List<EmpolyeeModel> empModel = [];
  bool _showData = true, _isLoading = true, isCached = false;
  LoadAllEmpAsync() async {
    setState(() {
      _showData = true;
    });
    print('beforeshowData::$_showData');
    var tlvStr =
        "select fullname,usrname,usrid,role,type,level,tusertbl.status,mobno from tskmgmt.uroletbl,tskmgmt.tusertbl where usrid=uid order by usrname;";

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
          glb.showSnackBar(context, 'Error', 'No Employee Found');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = false;
          });
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var FullNm = userMap['1'];
            var UsrName = userMap['2'];
            var UsrId = userMap['3'];
            var role = userMap['4'];
            var type = userMap['5'];
            var lvl = userMap['6'];
            var status = userMap['7'];
            var mobno = userMap['8'];

            List FullNmLst = glb.strToLst(FullNm);
            List UsrNmLst = glb.strToLst(UsrName);
            List UsridLst = glb.strToLst(UsrId);
            List roleLst = glb.strToLst(role);
            List typeLst = glb.strToLst(type);
            List lvlLst = glb.strToLst(lvl);
            List stsLst = glb.strToLst(status);
            List mobNoLst = glb.strToLst(mobno);

            for (int i = 0; i < UsridLst.length; i++) {
              empModel.add(EmpolyeeModel(
                  EmpId: UsridLst.elementAt(i),
                  EmpName: UsrNmLst.elementAt(i),
                  Role: roleLst.elementAt(i),
                  mobNo: mobNoLst.elementAt(i)));
            }
            print('usrnm: $UsrName');
            print('UsrId: $UsrId');
            print('status:: $status');

            setState(() {
              empModelCache = List.from(empModel);
              _isLoading = false;
              _showData = false;
              isCached = true;
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

  TextEditingController fullNameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController unameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // glb.showLoaderDialog(context, _isLoading);
    LoadAllEmpAsync();
  }

  List<EmpolyeeModel> empModelCache = [];
  void filterSearchResults(String query) {
    List<EmpolyeeModel> dummySearchList = [];
    dummySearchList.clear();
    dummySearchList.addAll(empModelCache);
    if (query.isNotEmpty) {
      List<EmpolyeeModel> dummyListData = [];

      final suggestions = dummySearchList.where((element) {
        final nameTitle = element.EmpName.toLowerCase();
        final input = query.toLowerCase();
        print(nameTitle);
        print(input);
        return nameTitle.contains(input);
      }).toList();

      setState(() {
        empModel.clear();
        empModel = suggestions;
        //taskModel.addAll(dummyListData);
      });
      return;
    } else {
      print('return to normal $empModelCache');
      setState(() {
        empModel.clear();
        empModel.addAll(empModelCache);
      });
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50.0,
                  width: width - 20,
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
                        hintText: 'Search User Name Here',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        LoadAllEmpAsync();
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
                        LoadAllEmpAsync();
                      },
                      child: ListView.separated(
                          itemCount: empModel.length,
                          separatorBuilder: (context, _) =>
                              SizedBox(height: height * 0.02),
                          itemBuilder: ((context, index) {
                            return EmployeeCard(
                                width: width,
                                height: height,
                                model: empModel[index]);
                          })),
                    ),
                  )
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

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    Key? key,
    required this.width,
    required this.height,
    required this.model,
  }) : super(key: key);

  final double width;
  final double height;
  final EmpolyeeModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              glb.EmpID = model.EmpId.toString();
              glb.EmpName = model.EmpName.toString();
              showAlert(context, model);
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
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                  title: model.EmpName,
                                  fontsize: 14.0,
                                  color: AppColors.blueDarkColor),
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_pin_circle_outlined,
                                    color: Colors.red,
                                    size: 15.0,
                                  ),
                                  TextWidget(
                                      title: 'Role : ${model.Role}',
                                      fontsize: 10.0,
                                      color: AppColors.textColor),
                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.pink,
                                    size: 15.0,
                                  ),
                                  TextWidget(
                                      title: 'Mobile No : ${model.mobNo}',
                                      fontsize: 10.0,
                                      color: AppColors.textColor),
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
                             /*  Row(
                                children: [
                                  Icon(
                                    Icons.stacked_bar_chart,
                                    color: Colors.greenAccent,
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
                                  Text('Projects Assigned',
                                      style: ralewayStyle.copyWith(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ],
                              ) */
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

void showAlert(BuildContext context, EmpolyeeModel model) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                  title: 'Employee Name : ${model.EmpName}',
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
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Uri mobno = Uri.parse("tel://${model.mobNo}");
                      UrlLauncher.launchUrl(mobno);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.amber,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: AppColors.whiteColor,
                            ),
                            Text(
                              'Call This Employee',
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
                      //Navigator.pop(context);
                      glb.EmpID = model.EmpId.toString();
                      Navigator.pushNamed(context, AddEmployeeRoute);
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
                              'Update/View Employee',
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
                      glb.assignRegion = true;
                      glb.region_controls = false;
                      glb.AssignBtn = true;
                      glb.NextBtn = false;
                      glb.region_full_query = 1;
                      glb.ActionVal = 1;
                      if (glb.lastCacheRegionType == 2) {
                        glb.CityCache = 0;
                        glb.CountryCache = 0;
                        glb.DistCache = 0;
                        glb.StateCache = 0;
                        glb.TalukCache = 0;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegionManagement()));
                      // showRegionManagementPop(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.purple,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              color: Colors.white,
                            ),
                            Text(
                              'Assign Region',
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
                      glb.assignProject = true;
                      glb.EmpID = model.EmpId.toString();
                      Navigator.pushNamed(context, AllProjectsRoute);
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
                              'Delete Employee',
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
        Text('Employee Management',
            style: ralewayStyle.copyWith(
              fontSize: 16.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              glb.EmpID = '';
              Navigator.pushNamed(context, AddEmployeeRoute);
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Ink(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Add Employee +',
                    style: ralewayStyle.copyWith(
                      fontSize: 10.0,
                      color: AppColors.whiteColor,
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
