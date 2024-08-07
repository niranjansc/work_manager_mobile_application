import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/settingsPages/wallet/earnModel.dart';
import 'package:work_manager/settingsPages/wallet/ernCard.dart';
import 'package:work_manager/settingsPages/wallet/paidCard.dart';
import 'package:work_manager/settingsPages/wallet/paidModel.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:http/http.dart' as http;

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myBalAsync();
    myErngDetAsync();
  }

  bool _showData = true;
  List InstNm = [], Date_lst = [], amt_lst = [], ern_lst = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.arrow_back_ios_new),
                            )),
                        Row(
                          children: const [
                            TextWidget(
                                title: 'Account Management',
                                fontsize: 16,
                                color: AppColors.blueDarkColor),
                          ],
                        ),
                        const Icon(Icons.notifications_active_outlined),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.backColor),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                      title: 'Main Wallet',
                                      fontsize: 16,
                                      color: AppColors.blueDarkColor),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200]),
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundImage: NetworkImage(
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK_vjpKVAjkub5O0sFL7ij3mIzG-shVt-6KKLNdxq4&s'),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              InkWell(
                                onTap: () {
                                  urEarng_popUp();
                                },
                                child: TextWidget(
                                    title: 'Your earnings',
                                    fontsize: 14,
                                    color: AppColors.greyColor),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              TextWidget(
                                  title: "Rs. ${glb.earnings}",
                                  fontsize: 14,
                                  color: AppColors.textColor),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              InkWell(
                                onTap: () {
                                  paid_popUp();
                                },
                                child: TextWidget(
                                    title: 'Paid',
                                    fontsize: 14,
                                    color: AppColors.greyColor),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              TextWidget(
                                  title: "Rs. ${glb.paid}",
                                  fontsize: 14,
                                  color: AppColors.textColor),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              TextWidget(
                                  title: 'Balance',
                                  fontsize: 14,
                                  color: AppColors.greyColor),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              TextWidget(
                                  title: "Rs. ${glb.balance}",
                                  fontsize: 14,
                                  color: AppColors.textColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  urEarng_popUp() {
    print("pop up");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Your earnings"),
            content: SizedBox(
              width: double.infinity,
              child: ListView.builder(
                  itemCount: EM.length,
                  itemBuilder: (BuildContext context, index) {
                    return ErnCrd(
                      dataModel: EM[index],
                    );
                  }),
            ),
          );
        });
  }

  paid_popUp() {
    print("pop up");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Paid"),
            content: SizedBox(
              width: double.infinity,
              child: ListView.builder(
                  itemCount: PM.length,
                  itemBuilder: (BuildContext context, index) {
                    return paidCard(
                      dataModel: PM[index],
                    );
                  }),
            ),
          );
        });
  }

  myBalAsync() async {
    setState(() {
      _showData = true;
    });

    var tlvStr =
        "select payable from tskmgmt.paymentsbtbl where usrid=${glb.userID};";
    print('queryName::$tlvStr');
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
          glb.showSnackBar(context, 'Error', 'No Tasks Found');
          setState(() {
            _showData = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("taskMap:$userMap");

            var payable = userMap['1'];

            glb.Payable_Lst = glb.strToLst(payable);

            glb.earnings = 0;
            glb.paid = 0;
            glb.balance = 0;
            for (int i = 0; i < glb.Payable_Lst.length; i++) {
              int p = int.parse(glb.Payable_Lst[i]);
              print("p = $p");
              if (p >= 0) {
                glb.earnings = glb.earnings + p;
              }
              if (p < 0) {
                glb.paid = glb.paid + (-1 * p);
              }
            }

            glb.balance = glb.earnings - glb.paid;

            print("tot = ${glb.paid}");

            setState(() {});

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
  }

  List<ErnModel> EM = [];
  List<PaidModel> PM = [];
  myErngDetAsync() async {
    setState(() {
      _showData = true;
    });

    var tlvStr =
        "select paymentsbtbl.taskid,tasktbl.instname,installmenttbl.paydt,installmenttbl.amnt,payable,dt from tskmgmt.paymentsbtbl,tskmgmt.installmenttbl,tskmgmt.tasktbl where paymentsbtbl.taskid = installmenttbl.taskid and paymentsbtbl.instlid = installmenttbl.instlid and tskmgmt.paymentsbtbl.taskid = tskmgmt.tasktbl.taskid and tskmgmt.paymentsbtbl.usrid = ${glb.userID}";
    print('queryName::$tlvStr');
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
          glb.showSnackBar(context, 'Error', 'No Tasks Found');
          setState(() {
            _showData = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("taskMap:$userMap");

            var tskid = userMap['1'];
            var instNm = userMap['2'];
            var date = userMap['3'];
            var amt = userMap['4'];
            var erng = userMap['5'];
            var rcv_dt = userMap['6'];

            print("tskid ${tskid}");
            print("tskid ${instNm}");
            print("tskid ${date}");
            print("tskid ${amt}");
            print("tskid ${erng}");
            print(":rcvdate ${rcv_dt}");

            List instnm_Lst = glb.strToLst(instNm);
            List date_Lst = glb.strToLst(date);
            List amt_Lst = glb.strToLst(amt);
            List Comission = glb.strToLst(erng);
            List rcvDt_lst = glb.strToLst(rcv_dt);

            for (int i = 0; i < instnm_Lst.length; i++) {
              if (int.parse(Comission[i]) > 0) {
                EM.add(ErnModel(
                    Instnm: instnm_Lst[i],
                    Date: date_Lst[i],
                    amt: amt_Lst[i],
                    Erng: Comission[i]));
              } else if (int.parse(Comission[i]) < 0) {
                PM.add(PaidModel(Date: rcvDt_lst[i], Erng: Comission[i]));
              }
              ;
            }

            glb.Payable_Lst = glb.strToLst(tskid);

            glb.balance = glb.earnings - glb.paid;

            print("tot = ${glb.paid}");

            setState(() {});

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
  }
}
