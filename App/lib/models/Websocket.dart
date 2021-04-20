import 'dart:async';
import 'dart:io';

class Websocket {
  final String url;
  Websocket(this.url,
      {this.onConnectCallback,
      this.onDisconnectCallback,
      this.onDataCallback,
      this.onErrorCallback});
  final void Function(dynamic) onDataCallback;
  final void Function(String) onErrorCallback;
  final void Function(String) onDisconnectCallback;
  final void Function() onConnectCallback;
  bool connected = false;
  WebSocket _webSocket;
  void connect() async {
    if (this.connected) return;
    Future<WebSocket> socket = WebSocket.connect(url, protocols: ["Arduino"])
        .timeout(Duration(seconds: 5));
    try {
      await socket.then((WebSocket ws) {
        _webSocket = ws;
        _webSocket.pingInterval = Duration(milliseconds: 5000);
        _webSocket.add("connected");
        if (onConnectCallback != null) {
          onConnectCallback();
          connected = true;
        }
        _webSocket.listen(receiveData, onError: (error) {
          if (onErrorCallback != null) {
            onErrorCallback(error);
          }
        }, onDone: () async {
          if (onDisconnectCallback != null) {
            onDisconnectCallback(
                '${_webSocket?.closeReason ?? "null"}:${_webSocket?.closeCode ?? "null"}');
            connected = false;
          }
          _webSocket?.close();
          _webSocket = null;

          //Retry connection in 5 Seconds
          await Future.delayed(Duration(seconds: 5), connect);
        });
      });
    } on TimeoutException {
      if (_webSocket != null) {
        _webSocket.close();
      }
      _webSocket = null;
      connect();
    } on Exception {
      print("exception");
    }
  }

  void receiveData(dynamic content) {
    if (onDataCallback != null) {
      onDataCallback(content);
    }
  }

  void send(dynamic message) {
    if (connected) {
      _webSocket.add(message);
    }
  }
}
