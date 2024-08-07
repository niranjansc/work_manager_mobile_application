import 'package:flutter/material.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;

class AdministrationPage extends StatefulWidget {
  const AdministrationPage({super.key});

  @override
  State<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: height * 0.05),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MainHeaders(),
                      const SizedBox(
                        height: 2.0,
                      ),
                      _HeadingSection(),
                      SizedBox(height: height * 0.03),
                      _HeadSection1(),
                      SizedBox(height: height * 0.03),
                      _WeeklyStatsCards(height: height, width: width),
                      SizedBox(height: height * 0.03),
                      _HeadSection2(),
                      SizedBox(height: height * 0.03),
                      Column(
                        children: [
                          _QuickControlCard(
                            width: width,
                            height: height,
                            index: 0,
                            title: 'Create Projects Panel',
                            color: Colors.green,
                            icon: Icons.add_box_outlined,
                          ),
                          _QuickControlCard(
                            width: width,
                            height: height,
                            index: 1,
                            title: 'Employee Management Panel',
                            color: Colors.orange,
                            icon: Icons.people_outlined,
                          ),
                          _QuickControlCard(
                            width: width,
                            height: height,
                            index: 2,
                            title: 'All Projects',
                            color: Colors.blue,
                            icon: Icons.file_present,
                          ),
                          _QuickControlCard(
                            width: width,
                            height: height,
                            index: 3,
                            title: 'Manage Region',
                            color: Colors.purple,
                            icon: Icons.location_on_sharp,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
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
        Text('Administrator',
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

class _QuickControlCard extends StatelessWidget {
  const _QuickControlCard({
    Key? key,
    required this.width,
    required this.height,
    required this.index,
    required this.title,
    required this.color,
    required this.icon,
  }) : super(key: key);

  final double width;
  final double height;
  final int index;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (index == 0) {
                    Navigator.pushNamed(context, CreateProjectsRoute);
                  } else if (index == 1) {
                    Navigator.pushNamed(context, EmployeeManagementRoute);
                  } else if (index == 2) {
                    Navigator.pushNamed(context, AllProjectsRoute);
                    //glb.showRegionManagementPop(context);
                  } else {
                    glb.region_full_query = 1;
                    glb.ActionVal = 1;
                    glb.CountryCache = 0;
                    glb.CityCache = 0;
                    glb.StateCache = 0;
                    glb.DistCache = 0;
                    glb.TalukCache = 0;
                    Navigator.pushNamed(context, CreateRegionRoute);
                  }
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Ink(
                  width: width - 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: AppColors.whiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: color,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        icon,
                                        color: AppColors.whiteColor,
                                      ),
                                    )),
                                SizedBox(height: height * 0.01),
                                SizedBox(width: width * 0.01),
                                Text(
                                  title,
                                  style: ralewayStyle.copyWith(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blueDarkColor),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_right)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }
}

class _WeeklyStatsCards extends StatelessWidget {
  const _WeeklyStatsCards({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatsCardLayout(
                width: width,
                color: Colors.deepOrange,
                title: 'Calls Done',
                index: 0,
                height: height,
                count: '0',
                icon: Icons.call_made_outlined,
              ),
              _StatsCardLayout(
                width: width,
                color: Colors.deepPurple,
                title: 'Leads Generated',
                index: 1,
                height: height,
                count: '0',
                icon: Icons.leaderboard,
              ),
            ],
          ),
          SizedBox(
            height: height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatsCardLayout(
                width: width,
                color: Colors.amber,
                title: 'Projects',
                index: 2,
                height: height,
                count: '0',
                icon: Icons.file_open_outlined,
              ),
              _StatsCardLayout(
                width: width,
                color: Colors.blueAccent,
                title: 'Employees',
                index: 3,
                height: height,
                count: '0',
                icon: Icons.emoji_people,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCardLayout extends StatelessWidget {
  const _StatsCardLayout({
    Key? key,
    required this.width,
    required this.color,
    required this.title,
    required this.index,
    required this.height,
    required this.count,
    required this.icon,
  }) : super(key: key);

  final double width;
  final Color color;
  final String title;
  final int index;
  final double height;
  final String count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: width * 0.47,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(1, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(icon, color: AppColors.whiteColor),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Text(
                      title,
                      style: ralewayStyle.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueDarkColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(count,
                    style: ralewayStyle.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor)),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.greenAccent,
                      size: 15.0,
                    ),
                    Text('13 % vs',
                        style: ralewayStyle.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    SizedBox(
                      width: width * 0.01,
                    ),
                    Text('last 7 days',
                        style: ralewayStyle.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadSection1 extends StatelessWidget {
  const _HeadSection1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Weekly Stats',
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Icon(
          Icons.query_stats,
          color: AppColors.mainBlueColor,
        )
      ],
    );
  }
}

class _HeadSection2 extends StatelessWidget {
  const _HeadSection2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Quick Controls',
          style: ralewayStyle.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDarkColor),
        ),
        Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.mainBlueColor,
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
        Text('Hello ${glb.userName} 👋',
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
            Text('Manage All The Administrator Settings Here',
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
