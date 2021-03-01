import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConnectionManager with ChangeNotifier {
  bool connected = false;
  final String url = "ws://192.168.178.74:81";

  ConnectionManager() {
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
      _webSocket.close();
      _webSocket = null;
      print('Connection Timeout');
      connect();
    }
  }

  _connected() {
    connected = true;
    notifyListeners();
  }

  _disconnected() {
    connected = false;
    notifyListeners();
  }

  _state() {
    switch (_webSocket.readyState) {
      case WebSocket.connecting:
        print("Websocket connection");
        break;
      case WebSocket.open:
        print("Websocket open");
        break;
      case WebSocket.closing:
        print("Websocket closing");
        break;
      case WebSocket.closed:
        print("Websocket closed");
        break;
    }
  }

  void send(String message) {
    if (connected) {
      _webSocket.add(message);
    }
  }
}
