library global;

import 'package:flutter/material.dart';
import 'package:work_manager/dynamicPages/buttonWidget.dart';
import 'package:work_manager/dynamicPages/textwidget.dart';
import 'package:work_manager/globalPages/cacheglb.dart';
import 'package:work_manager/utils/app_colors.dart';
import 'package:work_manager/utils/app_styles.dart';
import 'package:work_manager/globalPages/workglb.dart' as glb;

showLeadManagementPop(BuildContext context) {
  showModalBottomSheet<void>(
    // context and builder are
    // required properties in this widget
    context: context,
    builder: (BuildContext context) {
      // we set up a container inside which
      // we create center column and display text

      // Returning SizedBox instead of a Container
      TextEditingController selectController = TextEditingController();
      return SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 15.0,
            ),
            TextWidget(
                title: 'Create / Assign Tasks',
                fontsize: 22,
                color: AppColors.textColor),
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
                controller: selectController,
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
                        selectController.text = value;
                        glb.TaskTypeVal = value;
                        print("selected role type: $value");
                      },
                      itemBuilder: (BuildContext context) {
                        return glb.TaskType.map<PopupMenuItem<String>>(
                            (String value) {
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
              height: 15.0,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                    var tt = selectController.text;
                    if (tt.isEmpty) {
                      glb.showSnackBar(
                          context, 'Alert', 'Please Select the Type');
                      return;
                    }
                    print("tt::$tt");
                    if (tt == "lead gen") {
                      // DistCache = CountryCache =
                      //     StateCache = CityCache = TalukCache = 0;
                      glb.region_full_query = 0;
                      glb.region_controls = false;
                      glb.ActionVal = 2;
                      glb.assignRegion = false;
                      if (glb.lastCacheRegionType == 1) {
                        glb.CityCache = 0;
                        glb.CountryCache = 0;
                        glb.DistCache = 0;
                        glb.StateCache = 0;
                        glb.TalukCache = 0;
                      }
                      //Navigator.pop(context);
                      //showRegionManagementPop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegionManagement()));
                    }
                  },
                  borderRadius: BorderRadius.circular(16.0),
                  child: Ink(child: ButtonWidget(title: 'Next'))),
            )
          ],
        ),
      );
    },
  );
}
