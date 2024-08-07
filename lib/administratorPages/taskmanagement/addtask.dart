import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/administratorPages/taskmanagement/alltask.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/edittextWidget.dart';
import 'package:work_manager/dynamicPages/mobile_edittext.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:http/http.dart' as http;

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

enum SingingCharacter { YES, NO }

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController instNameController = TextEditingController();
  TextEditingController pocNameController = TextEditingController();
  TextEditingController pocPostionController = TextEditingController();
  TextEditingController pocNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  SingingCharacter? _character = SingingCharacter.YES;
  var usingSW = 0;
  List<String> tasks = <String>[
    '1-10 State',
    '1-10 CBSE',
    '1-10 ICSE',
    'Diploma',
    'PUC',
    'Engineering',
    'Medical',
    'Nursing',
    'Paramedic',
  ];
  var instName = '';
  var pocName = '';
  var pocNumber = '';
  var pocPosition = '';
  var description = '';
  var type = '';

  CreateTaskAync() async {
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs!.getString('userId');
    glb.userID = uid!;
    var name = glb.prefs!.getString('userName');
    glb.userName = name!;
    print("tsk async");
    var tlvStr =
        "insert into tskmgmt.tasktbl(ownername,cityid,status,ownerid,holderid,asid,dsc,instname,insttype,isusing,tasktype,pocname,pocno,pocdesignation) values('${glb.userName}','${glb.CityID}','1','${glb.userID}','${glb.userID}','${glb.assid}','${description}','${instName}','${type}','${usingSW}','${glb.TaskTyp}','$pocName','$pocNumber','$pocPosition') returning taskid; "; //pocName,pocNumber,pocPosition

    print(" crt tsk tlv: $tlvStr");
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
      print("REsponse::${response.body}");

      if (response.statusCode == 200 || response.statusCode == 400) {
        // print('response code:${res}');
        if (response.body.contains("ErrorCode#2")) {
          glb.showSnackBar(context, 'Error', 'No Data Found');
          return;
        } else if (response.body.contains("ErrororCode#8") ||
            response.body.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          //glb.showSnackBar('admin');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            taskid = userMap['1'];

            print('tskid: $taskid');
            updtPhaseAsync();
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      } else if (response.statusCode == 500) {
        print('500');
        updtPhaseAsync();
      }
    } catch (e) {
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  var taskid = '';

  updtPhaseAsync() async {
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs!.getString('userId');
    glb.userID = uid!;
    var tlvStr =
        "insert into tskmgmt.taskphase(taskid,phase,assid,ownerid,holderid,dtfrm,dtto,epochfrm,epochto,status,phasedsc) values($taskid,'CREATED',${glb.assid},'${glb.userID}','${glb.userID}',CURRENT_DATE,CURRENT_DATE, cast(extract(epoch from now()) as integer), cast(extract(epoch from now()) as integer)+600,1,'${description}');";

    print(" updt tlv: $tlvStr");
    String url = glb.endPoint;

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
          glb.showSnackBar(context, 'Success', 'Task Created Successfully');
          Navigator.pop(context);
          Navigator.pushNamed(context, LoadTaskRoute);

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          Navigator.pop(context);
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var taskid = userMap['1'];

            print('usrnm: $taskid');
            Navigator.pop(context);
            Navigator.pushNamed(context, LoadTaskRoute);
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
      appBar: AppBar(
        title: _MainHeaders(),
      ),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Institute Name',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50.0,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: instNameController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.file_copy_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter Institute Name',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Point Of Contact Name',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50.0,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: pocNameController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.file_copy_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter POC Name',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Point Of Contact Position',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50.0,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: pocPostionController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.file_copy_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter POC Position',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Point Of Contact Number',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: pocNumberController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.call),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter POC Mobile Number',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Description (optional)',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50.0,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextFormField(
                    controller: descriptionController,
                    style: ralewayStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.file_copy_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter Description Here',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Type Of',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 50.0,
                  width: width - 25,
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
                            print("selected role type: $value");
                          },
                          itemBuilder: (BuildContext context) {
                            return tasks
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
                SizedBox(
                  height: height * 0.02,
                ),
                TextWidget(
                    title: 'Using Software ?',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: height * 0.01,
                ),
                Column(
                  children: [
                    ListTile(
                      title: const Text('YES'),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.YES,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            usingSW = 1;
                            _character = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('NO'),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.NO,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            usingSW = 0;
                            _character = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        instName = instNameController.text;
                        pocName = pocNameController.text;
                        pocNumber = pocNumberController.text;
                        pocPosition = pocPostionController.text;
                        description = descriptionController.text;
                        type = typeController.text;

                        if (instName.isEmpty) {
                          glb.showSnackBar(
                              context, 'Error', 'Please Enter Institute Name');
                          return;
                        }

                        if (pocName.isEmpty) {
                          glb.showSnackBar(
                              context, 'Error', 'Please Enter POC Name');
                          return;
                        }
                        if (pocNumber.isEmpty) {
                          glb.showSnackBar(
                              context, 'Error', 'Please Enter POC Number');
                          return;
                        }

                        if (pocPosition.isEmpty) {
                          glb.showSnackBar(
                              context, 'Error', 'Please Enter POC Position');
                          return;
                        }
                        if (type.isEmpty) {
                          glb.showSnackBar(
                              context, 'Error', 'Please Select Type');
                          return;
                        }
                        if (description.isEmpty) {
                          description = "NA";
                          //return;
                        }
                        glb.showLoaderDialog(context, true);
                        CreateTaskAync();
                      },
                      borderRadius: BorderRadius.circular(16.0),
                      child: ButtonWidget(title: 'Create')),
                )
              ],
            ),
          ),
        ),
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
        Text('Add Task',
            style: ralewayStyle.copyWith(
              fontSize: 25.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.add,
              color: AppColors.whiteColor,
            ),
          ),
        )
      ],
    );
  }
}
