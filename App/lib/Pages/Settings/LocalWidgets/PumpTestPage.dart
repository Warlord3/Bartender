import 'package:bartender/bloc/DataManager.dart';
import 'package:flutter/material.dart';
import 'package:bartender/models/CommunicationData.dart';
import 'package:provider/provider.dart';

class PumpTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataManager dataManager =
        Provider.of<DataManager>(context, listen: false);
    return Center(
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemBuilder: (buildContext, index) {
            return PumpTest(dataManager, index);
          },
          itemCount: 16,
          shrinkWrap: true,
        ),
      ),
    );
  }
}

class PumpTest extends StatelessWidget {
  final DataManager dataManager;
  final int index;
  PumpTest(this.dataManager, this.index);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(index <= 9 ? "0$index." : "$index."),
        ElevatedButton(
            onPressed: () {
              dataManager.startPump(index, enPumpDirection.forward);
            },
            child: Text("Forward")),
        ElevatedButton(
            onPressed: () {
              dataManager.stopPump(index);
            },
            child: Text("Stop")),
        ElevatedButton(
            onPressed: () {
              dataManager.startPump(index, enPumpDirection.backward);
            },
            child: Text("Backward"))
      ],
    );
  }
}
