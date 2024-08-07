import 'package:flutter/material.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/SharedPreferencesUtils.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _MainHeaders(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _HeadingSection(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _MyProfileDetails(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _WalletAccount(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _LogOut(),
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

_onBackPressed(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const TextWidget(
          title: 'Are you sure?', fontsize: 18, color: AppColors.blueDarkColor),
      content: const Text('Do you want to Log Out'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(4),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Padding(
                      padding:  EdgeInsets.all(16.0),
                      child: TextWidget(
                          title: 'No',
                          fontsize: 12,
                          color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ),
             const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    SharedPreferenceUtils.save_val('userId', '');
                    Navigator.pushNamed(context, LoginRoute);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: TextWidget(
                            title: 'Yes',
                            fontsize: 12,
                            color: AppColors.whiteColor),
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
        Text('Settings',
            style: ralewayStyle.copyWith(
              fontSize: 25.0,
              color: AppColors.blueDarkColor,
              fontWeight: FontWeight.bold,
            )),
        WidgetCircularAnimator(
          size: 50,
          innerIconsSize: 3,
          outerIconsSize: 3,
          innerAnimation: Curves.easeInOutBack,
          outerAnimation: Curves.easeInOutBack,
          innerColor: Colors.deepPurple,
          outerColor: Colors.orangeAccent,
          innerAnimationSeconds: 10,
          outerAnimationSeconds: 10,
          child: Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
            child: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
              backgroundColor: Colors.transparent,
            ),
          ),
        )
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
            Text('Other Settings Related to User',
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

class _LogOut extends StatelessWidget {
  const _LogOut({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          /* SharedPreferenceUtils.save_val('userId', '');
          Navigator.pushNamed(context, LoginRoute); */
          _onBackPressed(context);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.backColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.logout_outlined,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: AppColors.greyColor,
                  height: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletAccount extends StatelessWidget {
  const _WalletAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AccountManagementRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.backColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.blue),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.account_balance,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Wallet',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: AppColors.greyColor,
                  height: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyProfileDetails extends StatelessWidget {
  const _MyProfileDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          /* SharedPreferenceUtils.save_val('userId', '');
          Navigator.pushNamed(context, LoginRoute); */
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.backColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color.fromARGB(255, 246, 0, 94)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person_pin_sharp,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: AppColors.greyColor,
                  height: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
