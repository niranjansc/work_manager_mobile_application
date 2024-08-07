library global;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;
import 'package:work_manager/routings/route_names.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:http/http.dart' as http;

bool stateShow = false, distShow = false, talukShow = false, cityShow = false;

class RegionManagement extends StatefulWidget {
  const RegionManagement({super.key});

  @override
  State<RegionManagement> createState() => _RegionManagementState();
}

class _RegionManagementState extends State<RegionManagement> {
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController talukController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    stateShow = false;
    distShow = false;
    talukShow = false;
    cityShow = false;
    getregionAsync(context);
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    stateShow = false;
    distShow = false;
    talukShow = false;
    cityShow = false;
    super.dispose();
  }

  getregionAsync(BuildContext context) async {
    // CountryMap[country];

    setState(() {
      stateShow = false;

      ;
    });
    glb.CntryLst.clear();
    glb.StateNMLst.clear();
    glb.DistNMLST.clear();
    glb.TalukNMLst.clear();
    glb.CityNMLst.clear();
    if (glb.CountryMap != null &&
        glb.CountryMap.length > 0 &&
        glb.CountryCache == 1) {
      //CountryMap
      glb.CntryLst.clear();
      glb.CntryIDLst.clear();

      for (MapEntry<String, glb.CountryObj> item in glb.CountryMap.entries) {
        glb.CntryLst.add(item.key);
        glb.CntryIDLst.add(item.value.CountryID);
      }
      print("Cache Built:${glb.CntryLst} and ${glb.CntryIDLst}");
      if (glb.CntryLst.length > 0 && glb.CntryIDLst.length > 0) {
        return;
      }
    }
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');

    var tlvStr = "";
    if (glb.region_full_query == 0) {
      glb.lastCacheRegionType = 2;
      tlvStr =
          "select distinct countrytbl.countryid,countrytbl.country from tskmgmt.countrytbl,tskmgmt.statetbl,tskmgmt.districttbl,tskmgmt.taluktbl,tskmgmt.citytbl,tskmgmt.lead_region_ass_tbl where lead_region_ass_tbl.cityid=citytbl.cityid and taluktbl.talukid=citytbl.talukid and districttbl.distid=taluktbl.distid and statetbl.stateid=districttbl.stateid and countrytbl.countryid=statetbl.countryid and usrid=$uid;";
    } else {
      glb.lastCacheRegionType = 1;
      tlvStr = "Select countryid,country from tskmgmt.countrytbl;";
    }
    print(" country tlv: $tlvStr");
    String url = glb.endPoint;

    final Map dict = {"tlvNo": "709", "query": tlvStr, "uid": "-1"};
    // CntryDDV = ' ';
    // StateDDV = ' ';
    // DistDDV = ' ';
    // TalukDDV = ' ';
    // CityDDV = ' ';
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
          Navigator.pop(context);
          glb.showSnackBar(context, 'Error', 'No Region Assigned');

          return;
        } else if (res.contains("ErrorCode#8")) {
          Navigator.pop(context);
          glb.showSnackBar(context, 'Error', 'Something went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("countryMap:$userMap");

            var CntryID = userMap['1'];
            var CntryNM = userMap['2'];

            glb.CntryIDLst = glb.strToLst(CntryID);
            glb.CntryLst = glb.strToLst2(CntryNM);
            print("cntryName::${glb.CntryLst}");
            //CntryLst = CntryNMLst.toString() as List<String>;
            glb.CntryIDLst = glb.CntryIDLst;

            //CountryMap
            for (int i = 0; i < glb.CntryLst.length; i++) {
              var country = glb.CntryLst.elementAt(i).toString();
              var id = glb.CntryIDLst.elementAt(i).toString();

              var countryMap = glb.CountryMap[country];
              if (countryMap == null) {
                countryMap = new glb.CountryObj();
              }
              countryMap.CountryID = id;
              countryMap.CounntryName = country;
              glb.CountryMap[country] = countryMap;
              //countryMap.StateMap = null;
            }
            //CntryDDV = CntryLst.first;
            print('ID: ${glb.CntryIDLst}');
            print('NM: ${glb.CntryLst}');
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      // setState(() {
      //   showLoading = true;
      // });
      Navigator.pop(context);
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  getStatesAsync(BuildContext context) async {
    glb.showLoaderDialog(context, true);
    if (glb.CountryMap != null &&
        glb.CountryMap.length > 0 &&
        glb.StateCache == 1) {
      var countryMap = glb.CountryMap[glb.CntryNM];
      print("countryMap:${countryMap}");
      if (countryMap != null && countryMap.StateMap != null) {
        glb.StateIDLst.clear();
        glb.StateNMLst.clear();
        for (MapEntry<String, glb.StateObj> item
            in countryMap.StateMap.entries) {
          glb.StateNMLst.add(item.key);
          glb.StateIDLst.add(item.value.StateID);
        }
        print("Cache Built:${glb.StateIDLst} and ${glb.StateNMLst}");
        if (glb.StateIDLst.length > 0 && glb.StateNMLst.length > 0) {
          setState(() {
            Navigator.pop(context);
            stateShow = true;
          });
          return;
        }
      }
    }
    print("ld States async");
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    var tlvStr = "";
    if (glb.region_full_query == 1) {
      tlvStr =
          "Select stateid,statename from tskmgmt.statetbl where countryid = '${glb.CntryID}';";
    } else {
      tlvStr =
          "select distinct statetbl.stateid,statetbl.statename  from tskmgmt.statetbl,tskmgmt.districttbl,tskmgmt.taluktbl,tskmgmt.citytbl,tskmgmt.lead_region_ass_tbl where lead_region_ass_tbl.cityid=citytbl.cityid and taluktbl.talukid=citytbl.talukid and districttbl.distid=taluktbl.distid and statetbl.stateid=districttbl.stateid and  usrid=${uid} and countryid='${glb.CntryID}'";
    }

    print(" State tlv: $tlvStr");
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
          glb.showSnackBar(context, 'Error', 'No State Found');
          setState(() {
            stateShow = false;
            distShow = false;
            talukShow = false;
            cityShow = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          glb.showSnackBar(context, 'Error', 'Something went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("stateMap:$userMap");

            var StateID = userMap['1'];
            var StateNM = userMap['2'];
            glb.StateIDLst = glb.strToLst(StateID);

            glb.StateNMLst = glb.strToLst2(StateNM);

            glb.StateDDV = glb.StateNMLst.first;
            var countryMap = glb.CountryMap[glb.CntryNM];
            if (countryMap == null) {
              countryMap = new glb.CountryObj();
            }
            if (countryMap.StateMap == null) {
              countryMap.StateMap = new Map<String, glb.StateObj>();
            }
            for (int i = 0; i < glb.StateIDLst.length; i++) {
              var stateid = glb.StateIDLst.elementAt(i).toString();
              var stateName = glb.StateNMLst.elementAt(i).toString();

              var sObj = new glb.StateObj();
              sObj.StateID = stateid;
              sObj.StateName = stateName;
              countryMap.StateMap[stateName] = sObj;
            }
            glb.StateCache = 1;

            glb.CountryMap[glb.CntryNM] = countryMap;

            // CntryLst = CntryNMLst;
            print('ID: ${glb.StateIDLst}');
            print('NM: ${glb.StateNMLst}');
            setState(() {
              Navigator.pop(context);
              stateShow = true;
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

  getDistAsync(BuildContext context) async {
    setState(() {
      distShow = false;
      glb.showLoaderDialog(context, true);
    });
    // DistCache = 0;
    if (glb.CountryMap != null &&
        glb.CountryMap.length > 0 &&
        glb.DistCache == 1) {
      var countryMap = glb.CountryMap[glb.CntryNM];
      print("countryMap:${countryMap}");
      if (countryMap != null && countryMap.StateMap != null) {
        var distObj = countryMap.StateMap[glb.StateNM];

        if (distObj!.DistrictMap.length > 0) {
          glb.DistIDLst.clear();
          glb.DistNMLST.clear();
          for (MapEntry<String, glb.DistrictObj> item
              in distObj.DistrictMap.entries) {
            glb.DistNMLST.add(item.key);
            glb.DistIDLst.add(item.value.DistrictID);
          }
          print("Dist Cache Built:${glb.DistIDLst} and ${glb.DistNMLST}");
          if (glb.DistNMLST.length > 0 && glb.DistIDLst.length > 0) {
            setState(() {
              distShow = true;
              Navigator.pop(context);
            });
            return;
          }
        }
      }
    }
    print("ld Dist async");
    var tlvStr = "";
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    if (glb.region_full_query == 1) {
      tlvStr =
          "Select distid,districtname from tskmgmt.districttbl where stateid = '${glb.StateID}';";
    } else {
      tlvStr =
          "select distinct districttbl.distid,districttbl.districtname from tskmgmt.districttbl,tskmgmt.taluktbl,tskmgmt.citytbl,tskmgmt.lead_region_ass_tbl where lead_region_ass_tbl.cityid=citytbl.cityid and taluktbl.talukid=citytbl.talukid and districttbl.distid=taluktbl.distid and   usrid=${uid} and  districttbl.stateid=${glb.StateID}";
    }

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
          print('err 2');

          glb.showSnackBar(context, 'Error', 'No District Found');
          setState(() {
            distShow = false;
            talukShow = false;
            cityShow = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          print('err 8');
          glb.showSnackBar(context, 'Error', 'Something went Wrong');
          return;
        } else {
          try {
            Map<String, dynamic> userMap = json.decode(response.body);
            print("dististMap:$userMap");

            var DistID = userMap['1'];
            var DistNM = userMap['2'];

            glb.DistIDLst = glb.strToLst(DistID);
            glb.DistNMLST = glb.strToLst2(DistNM);

            glb.DistDDV = glb.DistNMLST.first;

            var countryMap = glb.CountryMap[glb.CntryNM];
            if (countryMap == null) {
              countryMap = new glb.CountryObj();
            }
            if (countryMap.StateMap == null) {
              countryMap.StateMap = new Map<String, glb.StateObj>();
            }
            var stateObj = countryMap.StateMap[glb.StateNM];
            if (stateObj == null) {
              stateObj = new glb.StateObj();
            }

//stateObj.DistrictMap

            for (int i = 0; i < glb.DistIDLst.length; i++) {
              var distid = glb.DistIDLst.elementAt(i).toString();
              var distName = glb.DistNMLST.elementAt(i).toString();

              var dObj = new glb.DistrictObj();
              dObj.DistrictID = distid;
              dObj.DistrictName = distName;
              stateObj.DistrictMap[distName] = dObj;

              //countryMap.StateMap![stateName] = sObj;
            }
            glb.DistCache = 1;
            countryMap.StateMap[glb.StateNM] = stateObj;
            glb.CountryMap[glb.CntryNM] = countryMap;

            print('ID: ${glb.StateIDLst}');
            print('NM: ${glb.StateNMLst}');
            setState(() {
              distShow = true;
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

  getTalukaAsync(BuildContext context) async {
    print("ld taluk async");
    // TalukCache = 0;
    setState(() {
      talukShow = false;
      glb.showLoaderDialog(context, true);
    });
    if (glb.CountryMap != null &&
        glb.CountryMap.length > 0 &&
        glb.TalukCache == 1) {
      var countryMap = glb.CountryMap[glb.CntryNM];
      print("countryMap:${countryMap}");
      if (countryMap != null && countryMap.StateMap != null) {
        var distObj = countryMap.StateMap[glb.StateNM];

        if (distObj!.DistrictMap.length > 0) {
          var talkObj = distObj.DistrictMap[glb.DistNM];
          if (talkObj != null && talkObj.TalukMap.length > 0) {
            glb.TalukIDLst.clear();
            glb.TalukNMLst.clear();
            for (MapEntry<String, glb.TalukObj> item
                in talkObj.TalukMap.entries) {
              glb.TalukNMLst.add(item.key);
              glb.TalukIDLst.add(item.value.TalukID);
            }
            print("Tq Cache Built:${glb.TalukIDLst} and ${glb.TalukNMLst}");
            if (glb.TalukNMLst.length > 0 && glb.TalukIDLst.length > 0) {
              setState(() {
                talukShow = true;
                Navigator.pop(context);
              });
              return;
            }
          }
        }
      }
    }

    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    var tlvStr;
    if (glb.region_full_query == 1) {
      tlvStr =
          "Select talukid,talukname from tskmgmt.taluktbl where distid = '${glb.DistID}';";
    } else {
      tlvStr =
          "select distinct taluktbl.talukid,talukname  from tskmgmt.taluktbl,tskmgmt.citytbl,tskmgmt.lead_region_ass_tbl where lead_region_ass_tbl.cityid=citytbl.cityid and taluktbl.talukid=citytbl.talukid and    usrid=${uid} and  distid=${glb.DistID}";
    }

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
          print('err 2');

          glb.showSnackBar(context, 'Error', 'No Taluk Found');
          setState(() {
            talukShow = false;
            cityShow = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          print('err 8');
          glb.showSnackBar(context, 'Error', 'Something went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var TalukID = userMap['1'];
            var TalukNM = userMap['2'];
            glb.TalukIDLst = glb.strToLst(TalukID);
            glb.TalukNMLst = glb.strToLst2(TalukNM);

            print('glb tq id: ${glb.TalukIDLst}');
            print('glb tq nm : ${glb.TalukNMLst}');
            glb.TalukDDV = glb.TalukNMLst.first;
            var countryMap = glb.CountryMap[glb.CntryNM];
            if (countryMap == null) {
              countryMap = new glb.CountryObj();
            }
            if (countryMap.StateMap == null) {
              countryMap.StateMap = new Map<String, glb.StateObj>();
            }
            var stateObj = countryMap.StateMap[glb.StateNM];
            if (stateObj == null) {
              stateObj = new glb.StateObj();
            }
            var distObj = stateObj.DistrictMap[glb.DistNM];
            if (distObj == null) {
              distObj = new glb.DistrictObj();
            }

//stateObj.DistrictMap

            for (int i = 0; i < glb.TalukIDLst.length; i++) {
              var tqid = glb.TalukIDLst.elementAt(i).toString();
              var tqName = glb.TalukNMLst.elementAt(i).toString();

              var tObj = new glb.TalukObj();
              tObj.TalukID = tqid;
              tObj.TalukName = tqName;
              distObj.TalukMap[tqName] = tObj;

              //countryMap.StateMap![stateName] = sObj;
            }
            //  print("T MAP :${distObj.TalukMap}");
            glb.TalukCache = 1;
            stateObj.DistrictMap[glb.DistNM] = distObj;
            countryMap.StateMap[glb.StateNM] = stateObj;
            glb.CountryMap[glb.CntryNM] = countryMap;

            print('ID: ${glb.DistIDLst}');
            print('NM: ${glb.DistNMLST}');
            setState(() {
              talukShow = true;
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

  getCityAsync(BuildContext context) async {
    setState(() {
      cityShow = false;
      glb.showLoaderDialog(context, true);
    });
    glb.CityCache = 0;
    if (glb.CountryMap != null &&
        glb.CountryMap.length > 0 &&
        glb.CityCache == 1) {
      var countryMap = glb.CountryMap[glb.CntryNM];
      print("countryMap:${countryMap}");
      if (countryMap != null && countryMap.StateMap != null) {
        var distObj = countryMap.StateMap[glb.StateNM];

        if (distObj!.DistrictMap.length > 0) {
          var talkObj = distObj.DistrictMap[glb.DistNM];
          if (talkObj != null && talkObj.TalukMap.length > 0) {
            var cityObj = talkObj.TalukMap[glb.TalukNM];

            if (cityObj != null && cityObj.CityMap.length > 0) {
              glb.CityIDLst.clear();
              glb.CityNMLst.clear();
              print("CITY MAP :${cityObj.CityMap} ");
              for (MapEntry<String, glb.CityObj> item
                  in cityObj.CityMap.entries) {
                glb.CityNMLst.add(item.key);
                glb.CityIDLst.add(item.value.CityID);
              }
              print("City Cache Built:${glb.CityIDLst} and ${glb.CityNMLst}");
              if (glb.CityNMLst.length > 0 && glb.CityIDLst.length > 0) {
                setState(() {
                  cityShow = true;
                  Navigator.pop(context);
                });
                return;
              }
            }
          }
        }
      }
    }
    print("ld City async");
    glb.prefs = await SharedPreferences.getInstance();
    var uid = glb.prefs?.getString('userId');
    var tlvStr;
    if (glb.region_full_query == 1) {
      tlvStr =
          "Select cityid,cityname from tskmgmt.citytbl where talukid = '${glb.TalukID}';";
    } else {
      tlvStr =
          "select distinct citytbl.cityid,cityname from tskmgmt.citytbl,tskmgmt.lead_region_ass_tbl where lead_region_ass_tbl.cityid=citytbl.cityid and lead_region_ass_tbl.usrid=${uid};";
    }

    print(" city tlv: $tlvStr");
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
          print('err 2');
          glb.showSnackBar(context, 'Error', 'No City Found');
          setState(() {
            cityShow = false;
          });
          return;
        } else if (res.contains("ErrorCode#8")) {
          print('err 8');
          glb.showSnackBar(context, 'Error', 'Something  Went Wrong');
          return;
        } else {
          try {
            print('tri');
            Map<String, dynamic> userMap = json.decode(response.body);
            print("userMap:$userMap");

            var CityID = userMap['1'];
            var CityNM = userMap['2'];
            glb.CityIDLst = glb.strToLst(CityID);
            glb.CityNMLst = glb.strToLst2(CityNM);
            // CityNMLst = citynmlst.toString() as List<String>;
            glb.CityDDV = glb.CityNMLst.first;

            var countryMap = glb.CountryMap[glb.CntryNM];
            if (countryMap == null) {
              countryMap = new glb.CountryObj();
            }
            if (countryMap.StateMap == null) {
              countryMap.StateMap = new Map<String, glb.StateObj>();
            }
            var stateObj = countryMap.StateMap[glb.StateNM];
            if (stateObj == null) {
              stateObj = new glb.StateObj();
            }
            var distObj = stateObj.DistrictMap[glb.DistNM];
            if (distObj == null) {
              distObj = new glb.DistrictObj();
            }
            var tqObj = distObj.TalukMap[glb.TalukNM];
            if (tqObj == null) {
              tqObj = new glb.TalukObj();
            }

//stateObj.DistrictMap

            for (int i = 0; i < glb.CityIDLst.length; i++) {
              var tqid = glb.CityIDLst.elementAt(i).toString();
              var tqName = glb.CityNMLst.elementAt(i).toString();

              var tObj = new glb.CityObj();
              tObj.CityID = tqid;
              tObj.CityName = tqName;
              tqObj.CityMap[tqName] = tObj;

              //countryMap.StateMap![stateName] = sObj;
            }
            //  print("T MAP :${distObj.TalukMap}");
            glb.CityCache = 1;
            distObj.TalukMap[glb.TalukNM] = tqObj;
            stateObj.DistrictMap[glb.DistNM] = distObj;
            countryMap.StateMap[glb.StateNM] = stateObj;
            glb.CountryMap[glb.CntryNM] = countryMap;
            setState(() {
              cityShow = true;
              Navigator.pop(context);
            });
          } catch (e) {
            print(e);
            return "Failed";
          }
        }
      }
    } catch (e) {
      // setState(() {
      //   showLoading = true;
      Navigator.pop(context);
      glb.handleErrors(e, context);
    }

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
            title: 'Region Management',
            fontsize: 16,
            color: AppColors.whiteColor),
      ),
      backgroundColor: AppColors.backColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'Country',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextField(
                    controller: countryController,
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
                          icon: Icon(Icons.flag),
                        ),
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (String value) {
                            countryController.text = value;
                            print("selected country: $value");
                            glb.CntryDDV = value;
                            print('Dv: ${glb.CntryDDV}');
                            print('idx: ${value}');
                            var idx = glb.IndexOf(value, glb.CntryLst);
                            print('idx: $idx');
                            print("CntryIDLst:::${glb.CntryIDLst}");
                            print('cntry idx= ${glb.CntryIDLst[idx]}');
                            glb.CntryID = glb.CntryIDLst[idx];
                            glb.CntryNM = glb.CntryDDV;

                            glb.StateNMLst.clear();
                            glb.DistNMLST.clear();
                            glb.TalukNMLst.clear();
                            glb.CityNMLst.clear();
                            getStatesAsync(context);
                          },
                          itemBuilder: (BuildContext context) {
                            glb.CntryLst.toString();
                            return glb.CntryLst.map<PopupMenuItem<String>>(
                                (String value) {
                              return PopupMenuItem(
                                  child: Text(value), value: value);
                            }).toList();
                          },
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Select Country',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'State',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: stateShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: stateController,
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
                            icon: Icon(Icons.screen_lock_rotation_rounded),
                          ),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              stateController.text = value;
                              print("selected State: $value");
                              glb.StateDDV = value;
                              print('Dv: ${glb.StateDDV}');
                              var idx = glb.IndexOf(value, glb.StateNMLst);
                              print('idx: $idx');
                              print('State idx= ${glb.StateIDLst[idx]}');
                              glb.StateID = glb.StateIDLst[idx];
                              glb.StateNM = glb.StateDDV;
                              glb.DistNMLST.clear();
                              glb.TalukNMLst.clear();
                              glb.CityNMLst.clear();
                              getDistAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.StateNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select State',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'District',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: distShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: districtController,
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
                              districtController.text = value;
                              print("selected district: $value");
                              glb.DistDDV = value;
                              print('Dv: ${glb.DistDDV}');
                              var idx = glb.IndexOf(value, glb.DistNMLST);
                              print('idx: $idx');
                              print('State idx= ${glb.DistIDLst[idx]}');
                              glb.DistID = glb.DistIDLst[idx];
                              glb.DistNM = glb.DistDDV;
                              glb.TalukNMLst.clear();
                              glb.CityNMLst.clear();
                              getTalukaAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.DistNMLST.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select District',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'Taluk',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: talukShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: talukController,
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
                              talukController.text = value;
                              print("selected taluk: $value");
                              glb.TalukDDV = value;
                              print('Dv: ${glb.TalukDDV}');

                              var idx = glb.IndexOf(value, glb.TalukNMLst);
                              print('idx: $idx');
                              print('State idx= ${glb.TalukIDLst[idx]}');
                              glb.TalukID = glb.TalukIDLst[idx];
                              glb.TalukNM = glb.TalukDDV;
                              glb.CityNMLst.clear();
                              getCityAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.TalukNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select Taluk',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'City',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: cityShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: cityController,
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
                              cityController.text = value;
                              print("selected city: $value");
                              glb.CityDDV = value;
                              print('Dv: ${glb.CityDDV}');
                              var idx = glb.IndexOf(value, glb.CityNMLst);
                              print('idx: $idx');
                              print('city idx= ${glb.CityIDLst[idx]}');
                              glb.CityID = glb.CityIDLst[idx];
                              glb.CityNM = glb.CityDDV;
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.CityNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select City',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () {
                        var country = countryController.text;
                        var state = stateController.text;
                        var district = districtController.text;
                        var taluk = talukController.text;
                        var city = cityController.text;
                        if (country.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the country first');
                          return;
                        }
                        if (state.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the state first');
                          return;
                        }
                        if (district.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the district first');
                          return;
                        }
                        if (taluk.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the taluk first');
                          return;
                        }
                        if (city.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the city first');
                          return;
                        }
                        if (glb.assignRegion) {
                          glb.showLoaderDialog(context, true);
                          InsertEmpRegAsync(context);
                        } else {
                          Navigator.pushNamed(context, LoadTaskRoute);
                        }
                      },
                      child: glb.assignRegion == false
                          ? ButtonWidget(title: 'Next')
                          : ButtonWidget(title: 'Assign')),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
showRegionManagementPop(BuildContext context) {
  // showLoaderDialog(context, true);
  //getRegionsAsync(context);
  
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController talukController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  // showLoaderDialog(context, true);
  getregionAsync(context);
  showModalBottomSheet<void>(

    context: context,
    builder: (BuildContext context) {
      // we set up a container inside which
      // we create center column and display text

      // Returning SizedBox instead of a Container

      return SizedBox(
        height: 100 * 12,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'Region Management Panel',
                    fontsize: 22,
                    color: AppColors.textColor),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'Country',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColors.whiteColor,
                  ),
                  child: TextField(
                    controller: countryController,
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
                          icon: Icon(Icons.flag),
                        ),
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (String value) {
                            countryController.text = value;
                            print("selected country: $value");
                            glb.CntryDDV = value!;
                            print('Dv: ${glb.CntryDDV}');
                            print('idx: ${value}');
                            var idx = glb.IndexOf(value, glb.CntryLst);
                            print('idx: $idx');
                            print("CntryIDLst:::${glb.CntryIDLst}");
                            print('cntry idx= ${glb.CntryIDLst[idx]}');
                            glb.CntryID = glb.CntryIDLst[idx];
                            glb.CntryNM = glb.CntryDDV;

                            glb.StateNMLst.clear();
                            glb.DistNMLST.clear();
                            glb.TalukNMLst.clear();
                            glb.CityNMLst.clear();
                            getStatesAsync(context);
                          },
                          itemBuilder: (BuildContext context) {
                            glb.CntryLst.toString();
                            return glb.CntryLst.map<PopupMenuItem<String>>(
                                (String value) {
                              return PopupMenuItem(
                                  child: Text(value), value: value);
                            }).toList();
                          },
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Select Country',
                        hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor.withOpacity(0.5),
                            fontSize: 12.0)),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'State',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: stateShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: stateController,
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
                            icon: Icon(Icons.screen_lock_rotation_rounded),
                          ),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              stateController.text = value;
                              print("selected State: $value");
                              glb.StateDDV = value!;
                              print('Dv: ${glb.StateDDV}');
                              var idx = glb.IndexOf(value, glb.StateNMLst);
                              print('idx: $idx');
                              print('State idx= ${glb.StateIDLst[idx]}');
                              glb.StateID = glb.StateIDLst[idx];
                              glb.StateNM = glb.StateDDV;
                              glb.DistNMLST.clear();
                              glb.TalukNMLst.clear();
                              glb.CityNMLst.clear();
                              getDistAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.StateNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select State',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'District',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: distShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: districtController,
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
                              districtController.text = value;
                              print("selected district: $value");
                              glb.DistDDV = value!;
                              print('Dv: ${glb.DistDDV}');
                              var idx = glb.IndexOf(value, glb.DistNMLST);
                              print('idx: $idx');
                              print('State idx= ${glb.DistIDLst[idx]}');
                              glb.DistID = glb.DistIDLst[idx];
                              glb.DistNM = glb.DistDDV;
                              glb.TalukNMLst.clear();
                              glb.CityNMLst.clear();
                              getTalukaAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.DistNMLST.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select District',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'Taluk',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: talukShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: talukController,
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
                              talukController.text = value;
                              print("selected taluk: $value");
                              glb.TalukDDV = value!;
                              print('Dv: ${glb.TalukDDV}');

                              var idx = glb.IndexOf(value, glb.TalukNMLst);
                              print('idx: $idx');
                              print('State idx= ${glb.TalukIDLst[idx]}');
                              glb.TalukID = glb.TalukIDLst[idx];
                              glb.TalukNM = glb.TalukDDV;
                              glb.CityNMLst.clear();
                              getCityAsync(context);
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.TalukNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select Taluk',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextWidget(
                    title: 'City',
                    fontsize: 12.0,
                    color: AppColors.blueDarkColor),
                SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: cityShow,
                  child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextField(
                      controller: cityController,
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
                              cityController.text = value;
                              print("selected city: $value");
                              glb.CityDDV = value!;
                              print('Dv: ${glb.CityDDV}');
                              var idx = glb.IndexOf(value, glb.CityNMLst);
                              print('idx: $idx');
                              print('city idx= ${glb.CityIDLst[idx]}');
                              glb.CityID = glb.CityIDLst[idx];
                              glb.CityNM = glb.CityDDV;
                            },
                            itemBuilder: (BuildContext context) {
                              return glb.CityNMLst.map<PopupMenuItem<String>>(
                                  (String value) {
                                return PopupMenuItem(
                                    child: Text(value), value: value);
                              }).toList();
                            },
                          ),
                          contentPadding: const EdgeInsets.only(top: 16.0),
                          hintText: 'Select City',
                          hintStyle: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () {
                        var country = countryController.text;
                        var state = stateController.text;
                        var district = districtController.text;
                        var taluk = talukController.text;
                        var city = cityController.text;
                        if (country.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the country first');
                          return;
                        }
                        if (state.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the state first');
                          return;
                        }
                        if (district.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the district first');
                          return;
                        }
                        if (taluk.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the taluk first');
                          return;
                        }
                        if (city.isEmpty) {
                          glb.showSnackBar(context, 'Empty Field Alert',
                              'Please Select the city first');
                          return;
                        }
                        if (glb.assignRegion) {
                          InsertEmpRegAsync(context);
                        } else {
                          Navigator.pushNamed(context, LoadTaskRoute);
                        }
                      },
                      child: glb.assignRegion == false
                          ? ButtonWidget(title: 'Next')
                          : ButtonWidget(title: 'Assign')),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

*/
InsertEmpRegAsync(BuildContext context) async {
  print("insert emp region async");
  var tlvStr =
      "insert into tskmgmt.lead_region_ass_tbl(usrid,cityid) values('${glb.EmpID}','${glb.CityID}') returning id;";

  print(" login tlv: $tlvStr");
  String url = glb.endPoint;

  final Map dict = {"tlvNo": "714", "query": tlvStr, "uid": "-1"};

  try {
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dict));
    print('sts code: ${response.statusCode}');
    if (response.statusCode == 200) {
      var res = response.body;
      if (res.contains("ErrorCode#2")) {
        glb.showSnackBar(context, 'Alert', 'Plugin Error Try After Some time');
        return;
      } else if (res.contains("ErrororCode#8")) {
        glb.showSnackBar(context, 'Error', 'Something Went Wrong');
        return;
      } else if (res.contains("ErrorCode#0")) {
        glb.showSnackBar(context, 'Success', 'Region Assigned Successfully');
        Navigator.pop(context);
        Navigator.pop(context);
        return;
      } else {
        try {
          print('tri');
          Map<String, dynamic> userMap = json.decode(response.body);
          print("userMap:$userMap");

          var Uid = userMap['1'];
          glb.assignRegion = false;
          glb.showSnackBar(context, 'Success', 'Region Assigned Successfully');
          Navigator.pop(context);
          Navigator.pop(context);
        } catch (e) {
          print(e);
          return "Failed";
        }
      }
    } else if (response.statusCode == 400) {
      //print('888');
      glb.showSnackBar(context, 'Alert', 'Region Already Assigned');
      Navigator.pop(context);
      return;
    }
    ;
  } catch (e) {
    // setState(() {
    //   showLoading = true;
    // });

    glb.handleErrors(e, context);
  }

  return "Success";
}
