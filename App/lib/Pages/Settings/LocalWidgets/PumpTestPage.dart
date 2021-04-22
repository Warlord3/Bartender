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
  final TextEditingController controller = TextEditingController(text: "100");
  PumpTest(this.dataManager, this.index);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(index <= 9 ? "0$index." : "$index."),
              ElevatedButton(
                onPressed: () {
                  dataManager.startPump(index, enPumpDirection.forward);
                  dataManager.disablePumpInterupt();
                },
                child: Text("Forward"),
              ),
              ElevatedButton(
                onPressed: () {
                  dataManager.stopPump(index);
                  dataManager.enablePumpInterupt();
                },
                child: Text("Stop"),
              ),
              ElevatedButton(
                onPressed: () {
                  dataManager.startPump(index, enPumpDirection.backward);
                  dataManager.disablePumpInterupt();
                },
                child: Text("Backward"),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    dataManager.enablePumpInterupt();
                    dataManager.sendMilliliter(
                        this.index, int.parse(controller.text));
                  },
                  child: Text("Donate"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
