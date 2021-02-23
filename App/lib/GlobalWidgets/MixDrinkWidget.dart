import 'package:flutter/material.dart';

class MixDringWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 300),
        child: Container(
          width: 400,
          height: 200,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Text(
                      "Mix",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "{Name of the Drink} ?",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    disabledElevation: 1,
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(10.0),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    fillColor: Colors.green.withOpacity(0.3),
                    child: SizedBox(
                      child: Icon(
                        Icons.done,
                        color: Colors.green[700],
                        size: 40,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    disabledElevation: 1,
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(10.0),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    fillColor: Colors.red.withOpacity(0.3),
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
