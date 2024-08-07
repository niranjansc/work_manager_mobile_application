import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:work_manager/settingsPages/wallet/earnModel.dart';

class ErnCrd extends StatefulWidget {
  const ErnCrd({super.key, required this.dataModel});
  final ErnModel dataModel;

  @override
  State<ErnCrd> createState() => _ErnCrdState();
}

class _ErnCrdState extends State<ErnCrd> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Institute Name: ${widget.dataModel.Instnm}"),
              Text("Date: ${widget.dataModel.Date}"),
              Text("Amount: ${widget.dataModel.amt}"),
              Divider(
                color: Colors.black,
              ),
              Text("Earnings: ${widget.dataModel.Erng}")
            ],
          ),
        ),
      ),
    );
  }
}
