// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/models/multiProfilemodel.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/SharedPreferencesUtils.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/utils/responsive_widget.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;

class MultiProfilePage extends StatefulWidget {
  const MultiProfilePage({super.key});

  @override
  State<MultiProfilePage> createState() => _MultiProfilePageState();
}

class _MultiProfilePageState extends State<MultiProfilePage> {
  bool value = false, showBoder = false;
  int _selectedIndex = -1;
  List<MultiProfileModel> multiMode = [];
  var roleName = '', roleID = '';
  bool _isLoading = true;
  AsyncLoadRoles() async {
    prefs = await SharedPreferences.getInstance();
    List<String> rolesLst = prefs!.getStringList('uroleLst')!;
    List<String> usridLst = prefs!.getStringList('usridLst')!;
    List<String> usrNameLst = prefs!.getStringList('usrNameLst')!;

    print("usridLst::$usridLst");
    glb.userID = usridLst[0];
    for (int i = 0; i < rolesLst.length; i++) {
      multiMode.add(MultiProfileModel(
          roleName: rolesLst.elementAt(i),
          roleID: usridLst.elementAt(i),
          userName: usrNameLst.elementAt(i)));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    AsyncLoadRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SizedBox(
        width: width,
        height: height,
        child: Row(
          children: [
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveWidget.isSmallScreen(context)
                      ? height * 0.032
                      : height * 0.12),
              height: height,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.2,
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: 'Work Manager App',
                          style: ralewayStyle.copyWith(
                            fontSize: 25.0,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.normal,
                          )),
                    ])),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text(
                      'Hey,Automate Your Work 💼\n Smartly',
                      style: ralewayStyle.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: ' Choose Account Type👇',
                          style: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.blueDarkColor,
                            fontSize: 20.0,
                          ))
                    ])),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    SizedBox(
                      height: height * 0.3,
                      child: ListView.separated(
                          separatorBuilder: (context, _) => SizedBox(
                                height: height * 0.03,
                              ),
                          itemCount: multiMode.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                /* setState(() {
                                  showBoder = true;
                                }); */
                                setState(() {
                                  roleID = multiMode[index].roleID;
                                  roleName = multiMode[index].roleName;
                                  userName = multiMode[index].userName;
                                  SharedPreferenceUtils.save_val(
                                      'urole', roleName);
                                  SharedPreferenceUtils.save_val(
                                      'userName', userName);
                                  SharedPreferenceUtils.save_val(
                                      'userId', roleID);
                                  showBoder = false;
                                  if (_selectedIndex == index) {
                                    _selectedIndex = -1;
                                  } else {
                                    _selectedIndex = index;
                                    showBoder = true;
                                  }
                                });
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.whiteColor,
                                    border: index == _selectedIndex
                                        ? Border.all(
                                            color: AppColors.mainBlueColor)
                                        : Border.all(
                                            color: Colors.transparent)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[200]),
                                            child: const CircleAvatar(
                                              radius: 15.0,
                                              backgroundImage: NetworkImage(
                                                  'https://media.discordapp.net/attachments/1008571078211280957/1087760091920486460/Quicktunes_person_giving_online_demo_for_an_erp_software_cc29619d-c127-4433-b120-f772fc98a6e6.png?width=812&height=812'),
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.03,
                                          ),
                                          Column(
                                            children: [
                                              TextWidget(
                                                  title:
                                                      "I'm a ${multiMode[index].roleName}",
                                                  fontsize: 16,
                                                  color:
                                                      AppColors.blueDarkColor)
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_right_alt_rounded)
                                      /* Checkbox(
                                        value: this.value,
                                        onChanged: (value) {
                                          setState(() {
                                            this.value = value!;
                                            print(this.value);
                                          });
                                        },
                                      ), */
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (roleID.isEmpty) {
                              showSnackBar(context, 'alert',
                                  'Please Select The Account Type');
                              return;
                            }
                            Navigator.pushReplacementNamed(context, HomeRoute);
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 70.0, vertical: 18.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: AppColors.mainBlueColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Continue',
                                  style: ralewayStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.whiteColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_right_alt,
                                  color: AppColors.whiteColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
