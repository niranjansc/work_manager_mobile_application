// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/edittextWidget.dart';
import 'package:work_manager/dynamicPages/mobile_edittext.dart';
import 'package:work_manager/dynamicPages/passwordWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;
import 'package:work_manager/globalPages/workglb.dart' as glb;

class CreateNewEmployee extends StatefulWidget {
  const CreateNewEmployee({super.key});

  @override
  State<CreateNewEmployee> createState() => _CreateNewEmployeeState();
}

class _CreateNewEmployeeState extends State<CreateNewEmployee> {
  bool _showPassword = true;
  var Emp_lvl = '', Emp_role = '', Emp_OpenFor = '';
  TextEditingController fullNameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController unameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController openForController = TextEditingController();

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

  List roleIDLst = [];
  List<String> roleNameLst = [];
  List roleLevelLst = [];
  File? image;
  bool _showData = true, _isLoading = true, isCached = false;
  LoadAllRolesAsync() async {
    setState(() {
      _showData = true;
      roleIDLst.clear();
      roleNameLst.clear();
      roleLevelLst.clear();
    });

    var tlvStr = "select utypeid,desname,level from tskmgmt.usrtypes";

    print(" role Type tlv: $tlvStr");
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
          glb.showSnackBar(context, 'Error', 'No User Roles Found');
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
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var id = userMap['1'];
            var roleName = userMap['2'];
            var roleLevel = userMap['3'];

            roleIDLst = glb.strToLst2(id);
            roleNameLst = glb.strToLst2(roleName);
            roleLevelLst = glb.strToLst2(roleLevel);

            setState(() {
              roleNameLst = glb.strToLst2(roleName);
              if (glb.EmpID.isNotEmpty) {
                LoadUserDetailsAsync();
              } else {
                _isLoading = false;
              }
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

  LoadUserDetailsAsync() async {
    var tlvStr =
        "select  usrname,mobno,password,contactno,email,fullname,role,openfor from tskmgmt.tusertbl,tskmgmt.uroletbl where tusertbl.usrid=uroletbl.uid and tusertbl.usrid='${glb.EmpID}'";

    print(" user details tlv: $tlvStr");
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
          glb.showSnackBar(context, 'Error', 'No User Details Found');
          Navigator.pop(context);
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
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var usrname = userMap['1'];
            var mobno = userMap['2'];
            var pwd = userMap['3'];
            var contactno = userMap['4'];
            var email = userMap['5'];
            var fullName = userMap['6'];
            var role = userMap['7'];
            var openfor = userMap['8'];

            setState(() {
              fullNameController.text = fullName;
              roleController.text = role;
              unameController.text = usrname;
              mobileController.text = mobno;
              passwordController.text = pwd;
              openForController.text = openfor;
              _isLoading = false;
            });
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
    LoadAllRolesAsync();
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Column(
                          children: [
                            Stack(children: [
                              InkWell(
                                onTap: () {
                                  //pickImage();
                                  showSnackBar(
                                      context, 'Alert', 'Not Needed Yet');
                                },
                                child: Ink(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200]),
                                ),
                              ),
                              Positioned(
                                  left: 75,
                                  top: 65,
                                  child: Icon(Icons.add_a_photo)),
                            ]),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            TextWidget(
                                title: 'Upload Image',
                                fontsize: 12.0,
                                color: AppColors.blueDarkColor),
                            SizedBox(
                              height: height * 0.05,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                          title: 'Employee Full Name',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextFormField(
                                          controller: fullNameController,
                                          style: ralewayStyle.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.blueDarkColor,
                                              fontSize: 12.0),
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons
                                                    .person_add_alt_1_outlined),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText:
                                                  'Enter Employee Full Name Here',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      TextWidget(
                                          title: 'Employee Role',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50.0,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextField(
                                          controller: roleController,
                                          enableInteractiveSelection: false,
                                          focusNode: AlwaysDisabledFocusNode(),
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
                                              suffixIcon:
                                                  PopupMenuButton<String>(
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                onSelected: (String value) {
                                                  Emp_role = roleController
                                                      .text = value;
                                                  print(
                                                      "selected role type: $value");
                                                  setState(() {
                                                    var indexOf =
                                                        IndexOf(value, items);
                                                  });
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return roleNameLst.map<
                                                          PopupMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return PopupMenuItem(
                                                        child: Text(value),
                                                        value: value);
                                                  }).toList();
                                                },
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText: 'Select Role type',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      TextWidget(
                                          title: 'Open For (Ready To Work As)',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50.0,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextField(
                                          controller: openForController,
                                          enableInteractiveSelection: false,
                                          focusNode: AlwaysDisabledFocusNode(),
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
                                              suffixIcon:
                                                  PopupMenuButton<String>(
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                onSelected: (String value) {
                                                  Emp_OpenFor =
                                                      openForController.text =
                                                          value;
                                                  print(
                                                      "selected open for type: $value");
                                                  setState(() {
                                                    var indexOf =
                                                        IndexOf(value, items);
                                                    if (indexOf >= 0 &&
                                                        items.length >
                                                            indexOf) {
                                                      print('indx: $indexOf');
                                                    }
                                                    if (indexOf <= 3) {
                                                      print('lvl: 1');
                                                      Emp_lvl = '1';
                                                    } else if (indexOf > 3 &&
                                                        indexOf < 6) {
                                                      print('lvl: 2');
                                                      Emp_lvl = '2';
                                                    } else if (indexOf >= 6 &&
                                                        indexOf < 8) {
                                                      print('lvl: 3');
                                                      Emp_lvl = '3';
                                                    } else if (indexOf == 8) {
                                                      print('lvl: 4');
                                                      Emp_lvl = '4';
                                                    } else if (indexOf == 9) {
                                                      print('lvl: 5');
                                                      Emp_lvl = '5';
                                                    } else if (indexOf == 10) {
                                                      print('lvl: 10');
                                                      Emp_lvl = '10';
                                                    }
                                                  });
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return items.map<
                                                          PopupMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return PopupMenuItem(
                                                        child: Text(value),
                                                        value: value);
                                                  }).toList();
                                                },
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText:
                                                  'Select Open For Which Role',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      TextWidget(
                                          title: 'User Name',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextFormField(
                                          controller: unameController,
                                          style: ralewayStyle.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.blueDarkColor,
                                              fontSize: 12.0),
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.person),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText:
                                                  'Enter Employee Name Here',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      TextWidget(
                                          title: 'Mobile Number',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextFormField(
                                          controller: mobileController,
                                          style: ralewayStyle.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.blueDarkColor,
                                              fontSize: 12.0),
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.phone),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText:
                                                  'Enter Employee Mobile Number Here',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      TextWidget(
                                          title: 'Password',
                                          fontsize: 12.0,
                                          color: AppColors.blueDarkColor),
                                      SizedBox(
                                        height: height * 0.01,
                                      ),
                                      Container(
                                        height: 50,
                                        width: width - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: AppColors.whiteColor,
                                        ),
                                        child: TextFormField(
                                          keyboardType: TextInputType.name,
                                          controller: passwordController,
                                          style: ralewayStyle.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.blueDarkColor,
                                              fontSize: 12.0),
                                          obscureText: _showPassword,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                  onPressed: () {
                                                    if (_showPassword == true) {
                                                      setState(() {
                                                        _showPassword = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _showPassword = true;
                                                      });
                                                    }
                                                  },
                                                  icon: _showPassword
                                                      ? const Icon(
                                                          Icons.remove_red_eye)
                                                      : const Icon(Icons
                                                          .no_encryption_gmailerrorred_outlined)),
                                              prefixIcon: IconButton(
                                                onPressed: () {},
                                                icon:
                                                    const Icon(Icons.security),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 16.0),
                                              hintText:
                                                  'Enter Account Access Password Here',
                                              hintStyle: ralewayStyle.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blueDarkColor
                                                      .withOpacity(0.5),
                                                  fontSize: 12.0)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.04,
                                      ),
                                      glb.EmpID.isEmpty
                                          ? Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  onTap: () {
                                                    var fullName =
                                                        fullNameController.text;
                                                    if (fullName.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Full Name');
                                                      return;
                                                    }

                                                    var role =
                                                        roleController.text;
                                                    if (role.isEmpty ||
                                                        Emp_role.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Select Role Type');
                                                      return;
                                                    }

                                                    var openFor =
                                                        openForController.text;
                                                    if (openFor.isEmpty ||
                                                        Emp_lvl.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Select Open For Type');
                                                      return;
                                                    }

                                                    var uname =
                                                        unameController.text;
                                                    if (uname.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee User Name');
                                                      return;
                                                    }
                                                    var mobno =
                                                        mobileController.text;
                                                    if (mobno.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Mobile Number');
                                                      return;
                                                    }
                                                    var pwd =
                                                        passwordController.text;
                                                    if (pwd.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Login Password');
                                                      return;
                                                    }
                                                    /* if (glb.EmpID.isNotEmpty) {
                                            showLoaderDialog(context, true);
                                            CrtEmpAsyn(
                                                uname, mobno, pwd, fullName);
                                          } else {
                                            //updateAsync();
                                          } */
                                                    showLoaderDialog(
                                                        context, true);
                                                    CrtEmpAsyn(uname, mobno,
                                                        pwd, fullName);
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: ButtonWidget(
                                                      title: 'Create')),
                                            )
                                          : Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  onTap: () {
                                                    var fullName =
                                                        fullNameController.text;
                                                    if (fullName.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Full Name');
                                                      return;
                                                    }

                                                    var role =
                                                        roleController.text;
                                                    Emp_role = role;
                                                    if (role.isEmpty ||
                                                        Emp_role.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Select Role Type');
                                                      return;
                                                    }

                                                    var openFor =
                                                        openForController.text;
                                                    Emp_lvl = openFor;
                                                    if (openFor.isEmpty ||
                                                        Emp_lvl.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Select Open For Type');
                                                      return;
                                                    }

                                                    var uname =
                                                        unameController.text;
                                                    if (uname.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee User Name');
                                                      return;
                                                    }
                                                    var mobno =
                                                        mobileController.text;
                                                    if (mobno.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Mobile Number');
                                                      return;
                                                    }
                                                    var pwd =
                                                        passwordController.text;
                                                    if (pwd.isEmpty) {
                                                      showSnackBar(
                                                          context,
                                                          'Alert',
                                                          'Please Provide Employee Login Password');
                                                      return;
                                                    }
                                                    /* if (glb.EmpID.isNotEmpty) {
                                            showLoaderDialog(context, true);
                                            CrtEmpAsyn(
                                                uname, mobno, pwd, fullName);
                                          } else {
                                            //updateAsync();
                                          } */
                                                    showLoaderDialog(
                                                        context, true);
                                                    UpdateEmpAsync(uname, mobno,
                                                        pwd, fullName);
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: ButtonWidget(
                                                      title: 'Update')),
                                            )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  var CrtdUid;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      print('imageTemp::$imageTemp');
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  CrtEmpAsyn(
      String userName, String mobNo, String pwsd, String fullName) async {
    print("crt emp async");
    var tlvStr =
        "insert into tskmgmt.tusertbl(usrname,mobno,password,status,fullname) values('$userName','$mobNo','$pwsd',1,'$fullName') returning usrid;";

    print(" login tlv: $tlvStr");
    String url = endPoint;

    final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

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
        if (res.contains("ErrorCode#0")) {
          showSnackBar(context, 'Success', 'Employee Created Successfully');

          return;
        } else if (res.contains("ErrorCode#8")) {
          showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var Uid = userMap['1'];
            CrtdUid = Uid;

            updtrole();
            setState(() {
              _isLoading = false;
              _showData = true;
              isCached = true;
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      handleErrors(e, context);
    }

    return "Success";
  }

  updtrole() async {
    print("crt emp async");
    var tlvStr =
        "insert into tskmgmt.uroletbl(uid,status,type,openfor,level,role) values('$CrtdUid','1','1','$Emp_OpenFor','$Emp_lvl','$Emp_role');";

    print(" login tlv: $tlvStr");
    String url = endPoint;

    final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

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
        if (res.contains("ErrorCode#0")) {
          showSnackBar(context, 'Success', 'Employee Created Successfully');
          Navigator.pop(context);
          Navigator.pop(context);
          return;
        } else if (res.contains("ErrorCode#8")) {
          showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var Uid = userMap['1'];

            // for (int i = 0; i < UsridLst.length; i++) {
            //   empmod.add(EmpolyeeModel(
            //       EmpId: UsridLst.elementAt(i),
            //       EmpName: UsrNmLst.elementAt(i),
            //       Role: roleLst.elementAt(i)));
            // }

            print('UsrId: $Uid');

            setState(() {
              _isLoading = false;
              _showData = true;
              isCached = true;
            });
            Navigator.pop(context);
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      handleErrors(e, context);
    }

    return "Success";
  }

  UpdateEmpAsync(
      String userName, String mobNo, String pwsd, String fullName) async {
    var tlvStr =
        "update tskmgmt.tusertbl set usrname='$userName',mobno='$mobNo',password='$pwsd',fullname='$fullName' where usrid='${glb.EmpID}'; update tskmgmt.uroletbl set role='$Emp_role',openfor='$Emp_lvl' where uid='${glb.EmpID}';";

    print(" Update Emp Details tlv: $tlvStr");
    String url = endPoint;

    final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

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
        if (res.contains("ErrorCode#0")) {
          showSnackBar(
              context, 'Success', 'Employee Details Updated Successfully');
          Navigator.pop(context);
          Navigator.pop(context);
          return;
        } else if (res.contains("ErrorCode#8")) {
          showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var Uid = userMap['1'];

            // for (int i = 0; i < UsridLst.length; i++) {
            //   empmod.add(EmpolyeeModel(
            //       EmpId: UsridLst.elementAt(i),
            //       EmpName: UsrNmLst.elementAt(i),
            //       Role: roleLst.elementAt(i)));
            // }

            print('UsrId: $Uid');

            setState(() {
              _isLoading = false;
              _showData = true;
              isCached = true;
            });
            Navigator.pop(context);
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      handleErrors(e, context);
    }

    return "Success";
  }
}

class _MainHeaders extends StatelessWidget {
  const _MainHeaders({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              glb.EmpID.isEmpty
                  ? 'Add New Employee'
                  : 'Update Employee Details',
              style: ralewayStyle.copyWith(
                fontSize: 20.0,
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    ]);
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
