import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/edittextWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;

class CreateProjectsPage extends StatefulWidget {
  const CreateProjectsPage({super.key});

  @override
  State<CreateProjectsPage> createState() => _CreateProjectsPageState();
}

class _CreateProjectsPageState extends State<CreateProjectsPage> {
  var prjName = '';
  TextEditingController nameController = TextEditingController();
  FocusNode phoneFocusNode = new FocusNode();
  AsyncCreate() async {
    print("tsk async");
    var tlvStr = "insert into tskmgmt.tprojecttbl(prjname) values ('$prjName')";

    print(" insert Project Tlv: $tlvStr");
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
        if (response.body.contains("ErrorCode#2")) {
          print('err 2');

          return;
        } else if (response.body.contains("ErrororCode#8") ||
            response.body.contains("ErrorCode#8")) {
          print('err 8');

          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");
          } catch (e) {
            print(e);
            if (e.toString().contains("FormatException")) {
              Navigator.pop(context);
              Navigator.pop(context);
              showSnackBar(context, 'Success', 'Project created Successfully');
              return;
            }
            return "Failed";
          }
        }
      } else if (response.statusCode == 500) {
        print('500');
      }
    } catch (e) {
      handleErrors(e, context);
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
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: height * 0.02),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.01,
                      ),
                      WidgetCircularAnimator(
                        size: 150,
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
                              shape: BoxShape.circle, color: Colors.grey[200]),
                          child: CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(
                                'https://www.shutterstock.com/image-photo/new-project-word-on-notepad-260nw-293529491.jpg'),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      TextWidget(
                        title: 'Welcome Back',
                        fontsize: 25.0,
                        color: AppColors.blueDarkColor,
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      TextWidget(
                        title: 'Please Provide a Valid Project Name',
                        fontsize: 12.0,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Project Name',
                              style: ralewayStyle.copyWith(
                                fontSize: 12.0,
                                color: AppColors.blueDarkColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: AppColors.whiteColor,
                            ),
                            child: TextFormField(
                              controller: nameController,
                              style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blueDarkColor,
                                  fontSize: 12.0),
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.file_open_outlined),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(top: 16.0),
                                  hintText: 'Enter Project Name here',
                                  hintStyle: ralewayStyle.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor
                                          .withOpacity(0.5),
                                      fontSize: 12.0)),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () {
                              var nm = nameController.text;
                              print("prjName::$nm");
                              if (nm.isEmpty) {
                                showSnackBar(context, 'Alert',
                                    'Please Provide Project Name');
                                return;
                              }
                              prjName = nm;
                              showLoaderDialog(context, true);
                              AsyncCreate();
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: ButtonWidget(title: 'Create')),
                      )
                    ],
                  ),
                )
              ],
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
        Text('Create Projects',
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
