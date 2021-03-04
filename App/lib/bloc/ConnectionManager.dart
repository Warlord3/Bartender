import 'dart:async';
import 'dart:io';

import 'package:bartender/models/Drinks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConnectionManager with ChangeNotifier {
  bool connected = false;
  final String url = "ws://192.168.178.74:81";
  GlobalKey<ScaffoldState> scafoldKey;
  ConnectionManager() {
    scafoldKey = GlobalKey<ScaffoldState>();
    connect();
  }

  WebSocket _webSocket;
  void connect() async {
    print("Connection to $url");
    Future<WebSocket> socket = WebSocket.connect(url, protocols: ["Arduino"])
        .timeout(Duration(seconds: 5));
    try {
      await socket.then((WebSocket ws) {
        _webSocket = ws;
        _webSocket.pingInterval = Duration(milliseconds: 1000);
        _connected();
        _webSocket.add("connected");
        void onData(dynamic content) {
          print("Data:$content");
        }

        _webSocket.listen(onData,
            onError: (a) => print("error"),
            onDone: () async {
              print(_webSocket.closeReason);
              print(_webSocket.closeCode);
              _webSocket.close();
              print("Disconnected");
              _disconnected();
              await Future.delayed(Duration(seconds: 5));

              connect();
            });
      });
    } on TimeoutException catch (e) {
      if (_webSocket != null) {
        _webSocket.close();
      }
      _webSocket = null;
      print('Connection Timeout');
      print(e);
      connect();
    }
  }

  _connected() {
    connected = true;
    notifyListeners();
  }

  _disconnected() {
    connected = false;
    scafoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text("Disconnected"),
      duration: Duration(seconds: 2),
    ));
    notifyListeners();
  }

  sendDrink(Drink drink) {
    String message = "new_drink";
    message += "\$";
    message += "${drink.id}";
    message += ";";
    for (Ingredient ingredient in drink.ingredients) {
      message += "${ingredient.beverage.id}";
      message += ":";
      message += "${ingredient.amount}";
      message += ";";
    }
    send(message);
  }

  startPump(List<int> ids) {
    String message = "start_pump";
    message += "\$";
    for (int id in ids) {
      message += "$id:";
    }
    send(message);
  }

  stopPump(int id) {
    send("$id");
  }

  stopAllPumps() {
    send("stop_pump_all");
  }

  void send(String message) {
    if (connected) {
      _webSocket.add(message);
    }
  }
}
