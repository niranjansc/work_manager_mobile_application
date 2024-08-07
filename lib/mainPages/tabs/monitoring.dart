import 'package:flutter/material.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:work_manager/globalPages/workglb.dart';
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
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
                      _TaskMonitor(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _SummaryMonitor(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _CurrentTaskStatus(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _SuperConnectorMonitor(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _ConnectorMonitor(),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      _BDMMonitor(),
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
        Text('Monitor',
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
            Text('Live Statistics Reports/Progress',
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

class _TaskMonitor extends StatelessWidget {
  const _TaskMonitor({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          glb.roleFilter = "all";
          Navigator.pushNamed(context, TaskMonitorRoute); //TaskMonitorRoute
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.amber[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'Tasks assigned to me',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'View All the tasks assigned to you here.',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.amber[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.leaderboard),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMonitor extends StatelessWidget {
  const _SummaryMonitor({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, SummaryMonitorRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.green[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'Summary Monitor',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Detailed Summary Reports',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.green[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.summarize),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentTaskStatus extends StatelessWidget {
  const _CurrentTaskStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, CurrentTaskRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.purple[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'My running tasks',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Monitor All Your Task Here',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.purple[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.task),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuperConnectorMonitor extends StatelessWidget {
  const _SuperConnectorMonitor({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          glb.roleFilter = "Super Connector";
          Navigator.pushNamed(context, TaskMonitorRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.indigo[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'Super Connector tasks',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'View Your Regions and institutes here',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.indigo[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.task),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectorMonitor extends StatelessWidget {
  const _ConnectorMonitor({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          glb.roleFilter = "Connector";
          Navigator.pushNamed(context, TaskMonitorRoute);
          //Navigator.pushNamed(context, CurrentTaskRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.pink[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'Connector tasks',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'View Your Regions and institutes here',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.pink[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.task),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BDMMonitor extends StatelessWidget {
  const _BDMMonitor({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          glb.roleFilter = "BDM";
          Navigator.pushNamed(context, TaskMonitorRoute);
          //Navigator.pushNamed(context, CurrentTaskRoute);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))),
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
                                  'BDM tasks',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'View Your Regions and institutes here',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.task),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
