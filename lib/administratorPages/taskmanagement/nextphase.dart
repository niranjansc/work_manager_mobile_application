// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;

class NextPhase extends StatefulWidget {
  const NextPhase({super.key});

  @override
  State<NextPhase> createState() => _NextPhaseState();
}

class _NextPhaseState extends State<NextPhase> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nextPhaseController = TextEditingController();
  TextEditingController assignToController = TextEditingController();

  String toDate = 'Click to select To Date',
      fromDate = 'Click to select From Date';
  String phaseval = glb.PhaseLst.first;
  String Empval = glb.Empolyees.first;
  var PhaseDesc = 'NA';

  bool _showData = false, _isLoading = true, isCached = false;
  updtPhaseAsync() async {
    var tlvStr =
        "update tskmgmt.taskphase set status=0 where taskid=${glb.TaskId};insert into tskmgmt.taskphase(taskid,phase,assid,ownerid,holderid,dtfrm,dtto,epochfrm,epochto,status,phasedsc,prevphaseid,holdername) values(${glb.TaskId},'${phaseval}',${glb.assid},'${glb.userID}','${glb.holderid}','${glb.fdt}','${glb.Tdt}','${glb.Fepoch}', '${glb.Tepoch}',1,'${PhaseDesc}',${glb.PhaseId},'${Empval}'); update tskmgmt.tasktbl set status=2, holderid='${glb.holderid}' where taskid=${glb.TaskId}; ";

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
          glb.showSnackBar(context, 'Succcess', 'Task Updated Successfully');
          Navigator.pop(context);
          return;
        } else if (res.contains("ErrorCode#2")) {
          glb.showSnackBar(context, 'Error', 'Contact Admin No Data Found');
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var taskid = userMap['1'];

            print('usrnm: $taskid');

            setState(() {
              _isLoading = false;
              _showData = true;
              isCached = true;
            });
            glb.showSnackBar(context, 'Success', 'Phase Updated Successfully');
            Navigator.pop(context);

            return;
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

  IndexOf(param0, List empolyees) {
    if (empolyees == null || empolyees.length <= 0) return;
    for (int i = 0; i < empolyees.length; i++) {
      if (empolyees[i].toString().contains(param0)) return i;
    }
  }

  bool AllowOnlineDemo = false;
  AsyncCheckIfOnlineDemo(String usridEmp) async {
    var tlvStr =
        "select taskid from tskmgmt.taskphase where phase='Online Demo' and holderid='12' and status='1' and (( epochfrm>='${glb.Fepoch}' and epochto<='${glb.Fepoch}') or ( epochfrm>='${glb.Tepoch}' and epochto<='${glb.Tepoch}'));";

    print(" AsyncCheckIfOnlineDemo tlv: $tlvStr");
    String url = glb.endPoint;
    print(" AsyncCheckIfOnlineDemo tlv: ${glb.endPoint}");

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
          setState(() {
            _isLoading = false;
            _showData = false;
            isCached = true;
            AllowOnlineDemo = false;
            Navigator.pop(context);
          });

          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> foundMap = json.decode(response.body);
            print("foundMap:$foundMap");

            setState(() {
              glb.showSnackBar(context, 'Error',
                  'Already Online Demo is Assigned for This User For This Particular Time.');

              _isLoading = false;
              _showData = false;
              isCached = true;
              AllowOnlineDemo = true;
              Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: _MainHeaders()),
      backgroundColor: AppColors.backColor,
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  TextWidget(
                      title: 'Current Phase',
                      fontsize: 16.0,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  TextWidget(
                      title: '${glb.curTaskName}',
                      fontsize: 14.0,
                      color: AppColors.textColor),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  TextWidget(
                      title: 'Description',
                      fontsize: 12.0,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextFormField(
                      maxLines: null,
                      controller: descriptionController,
                      style: ralewayStyle.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.blueDarkColor,
                          fontSize: 12.0),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.description),
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Description',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  TextWidget(
                      title: 'Next Phase',
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
                      controller: nextPhaseController,
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
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              setState(() {
                                AllowOnlineDemo = false;
                                nextPhaseController.text = value;
                                phaseval = value;
                                print("selected phase type: $value");
                              });
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
                          hintText: 'Select Next Phase',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextWidget(
                              title:
                                  'Select the Initial Date and Time for this Particular Task',
                              fontsize: 14.0,
                              color: AppColors.textColor),
                          Row(
                            children: [
                              TextWidget(
                                  title: 'From Date :-',
                                  fontsize: 12.0,
                                  color: AppColors.blueDarkColor),
                              TextButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(2012, 3, 5),
                                      maxTime: DateTime(2030, 6, 7),
                                      theme: DatePickerTheme(
                                          itemStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          doneStyle: TextStyle(fontSize: 16)),
                                      onChanged: (date) {
                                    print('change $date in time zone ' +
                                        date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    var addZero = '';
                                    setState(() {
                                      if (date.month < 10) {
                                        addZero = '0';
                                      } else {
                                        addZero = '';
                                      }
                                      glb.fdt = fromDate =
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
                                child: TextWidget(
                                    title: fromDate,
                                    fontsize: 12,
                                    color: AppColors.mainBlueColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget(
                              title:
                                  'Select the Deadline Date and Time for this Particular Task',
                              fontsize: 14.0,
                              color: AppColors.textColor),
                          Row(
                            children: [
                              TextWidget(
                                  title: 'To Date :-',
                                  fontsize: 12.0,
                                  color: AppColors.blueDarkColor),
                              TextButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(2012, 3, 5),
                                      maxTime: DateTime(2030, 6, 7),
                                      theme: DatePickerTheme(
                                          itemStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          doneStyle: TextStyle(fontSize: 16)),
                                      onChanged: (date) {
                                    print('change $date in time zone ' +
                                        date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    var addZero = '';
                                    setState(() {
                                      if (date.month < 10) {
                                        addZero = '0';
                                      } else {
                                        addZero = '';
                                      }
                                      glb.Tdt = toDate =
                                          '${date.year}-$addZero${date.month}-${date.day}';
                                      glb.Tdt = date.toString();
                                      var parts = glb.Tdt.split(" ");
                                      glb.Tdt = parts[0].trim();
                                      print("toDate:${glb.Tdt}");
                                    });
                                    print(
                                        'confirm ${date.year}-${date.month}-${date.day}');
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                },
                                child: TextWidget(
                                    title: toDate,
                                    fontsize: 12,
                                    color: AppColors.mainBlueColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  TextWidget(
                      title: 'Assign To',
                      fontsize: 12.0,
                      color: AppColors.blueDarkColor),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextFormField(
                      maxLines: null,
                      controller: assignToController,
                      focusNode: AlwaysDisabledFocusNode(),
                      style: ralewayStyle.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.blueDarkColor,
                          fontSize: 12.0),
                      keyboardType: TextInputType.none,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              assignToController.text = value;
                              print("selected employee : $value");
                              setState(() {
                                Empval = value;
                                var usrid;
                                var indexOf = IndexOf(value, glb.Empolyees);
                                if (indexOf >= 0 &&
                                    glb.uidLst.length > indexOf) {
                                  usrid = glb.uidLst[indexOf];
                                  glb.holderid = usrid;
                                  print('user id= $usrid');
                                  if (descriptionController.text.isEmpty) {
                                    glb.showSnackBar(context, 'Required Error',
                                        'Please select the Description');
                                    return;
                                  }
                                  if (nextPhaseController.text.isEmpty) {
                                    glb.showSnackBar(context, 'Required Error',
                                        'Please select the Next Phase');
                                    return;
                                  }
                                  if (fromDate.contains('Click')) {
                                    glb.showSnackBar(context, 'Required Error',
                                        'Please select the From Date First');
                                    return;
                                  }

                                  if (toDate.contains('Click')) {
                                    glb.showSnackBar(context, 'Required Error',
                                        'Please select the To Date First');
                                    return;
                                  }

                                  var fdt = glb.fdt + " " + glb.ftm;
                                  print(fdt);
                                  var Tdt = glb.Tdt + " " + glb.Ttm;
                                  var finputdt = DateTime.parse(fdt);
                                  print('fint ${finputdt}');
                                  var tinpdt = DateTime.parse(Tdt);
                                  print('tint $tinpdt');
                                  var crteph =
                                      (finputdt.millisecondsSinceEpoch / 1000)
                                          .toInt();
                                  var fEpoch =
                                      ((finputdt.millisecondsSinceEpoch / 1000))
                                          .toInt();
                                  glb.Fepoch = fEpoch.toString();
                                  var tEpoch =
                                      ((tinpdt.millisecondsSinceEpoch / 1000))
                                          .toInt();
                                  glb.Tepoch = tEpoch.toString();
                                  if (phaseval == 'Online Demo') {
                                    glb.showLoaderDialog(context, true);
                                    AsyncCheckIfOnlineDemo(usrid);
                                  }
                                }
                                print("usrid::${glb.uidLst}");
                                print('indx: $indexOf');
                                print('Dv: $Empval');
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.Empolyees.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.description),
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Assign To',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  AllowOnlineDemo
                      ? Text('Choose Other Person For Online Demo')
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: () {
                                if (descriptionController.text.isEmpty) {
                                  glb.showSnackBar(context, 'Required Error',
                                      'Please select the Description');
                                  return;
                                }
                                if (nextPhaseController.text.isEmpty) {
                                  glb.showSnackBar(context, 'Required Error',
                                      'Please select the Next Phase');
                                  return;
                                }
                                if (fromDate.contains('Click')) {
                                  glb.showSnackBar(context, 'Required Error',
                                      'Please select the From Date First');
                                  return;
                                }

                                if (toDate.contains('Click')) {
                                  glb.showSnackBar(context, 'Required Error',
                                      'Please select the To Date First');
                                  return;
                                }

                                if (assignToController.text.isEmpty) {
                                  glb.showSnackBar(context, 'Required Error',
                                      'Please select the Employee To Assign');
                                  return;
                                }

                                PhaseDesc = descriptionController.text;
                                print('tap');
                                var fdt = glb.fdt;
                                print(fdt);
                                var Tdt = glb.Tdt;
                                var finputdt = DateTime.parse(fdt);
                                print('fint ${finputdt}');
                                var tinpdt = DateTime.parse(Tdt);
                                print('tint $tinpdt');
                                var crteph =
                                    (finputdt.millisecondsSinceEpoch / 1000)
                                        .toInt();
                                var fEpoch =
                                    ((finputdt.millisecondsSinceEpoch / 1000))
                                        .toInt();
                                glb.Fepoch = fEpoch.toString();
                                var tEpoch =
                                    ((tinpdt.millisecondsSinceEpoch / 1000))
                                        .toInt();
                                glb.Tepoch = tEpoch.toString();
                                updtPhaseAsync();
                              },
                              child: ButtonWidget(title: 'Update')),
                        ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                ],
              ),
            ),
          )
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
        Text('Next Phase',
            style: ralewayStyle.copyWith(
              fontSize: 25.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            )),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.create,
              color: AppColors.whiteColor,
            ),
          ),
        )
      ],
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
