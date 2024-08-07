import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:work_manager/settingsPages/wallet/paidModel.dart';

class paidCard extends StatefulWidget {
  const paidCard({super.key, required this.dataModel});
  final PaidModel dataModel;

  @override
  State<paidCard> createState() => _paidCardState();
}

class _paidCardState extends State<paidCard> {
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
              Text("Rcv Date: ${widget.dataModel.Date}"),
              Text("Amount: ${widget.dataModel.Erng}"),
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
