import 'dart:io';

import 'package:bartender/bloc/DataManager.dart';
import 'package:bartender/bloc/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionPage extends StatefulWidget {
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  LanguageManager languageManager;
  @override
  Widget build(BuildContext context) {
    languageManager = Provider.of<LanguageManager>(context, listen: false);
    return FutureBuilder(
      future: searchForWebsockets(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> data = snapshot.data;
          if (data.length == 0) {
            return Text("No Bartenders found");
          } else if (data.length == 1) {
            Provider.of<DataManager>(context, listen: false).ip = data.first;
            return Text("Found one Bartender with ip: ${data.first}");
          } else {
            //TODO list found Bartenders and select one
            return Text("found ${data.length} Bartenders");
          }
        } else {
          return Column(
            children: [
              Text(
                languageManager.getData("search_connection"),
              ),
              SizedBox(
                height: 20,
              ),
              CircularProgressIndicator(),
            ],
          );
        }
        return Text("There went something wrong");
      },
    );
  }

  Future<List<String>> searchForWebsockets() async {
    print("start");
    List<String> ips = [];
    for (int i = 0; i < 255; i++) {
      if (i == 254) {
        await ping("192.168.178.$i", Duration(seconds: 5), (ip) {
          ips.add(ip);
        });
      } else {
        ping("192.168.178.$i", Duration(seconds: 5), (ip) {
          ips.add(ip);
        });
      }
    }
    print("finished");
    return ips;
  }

  Future<bool> ping(
      String ip, Duration timeout, Function(String ip) callback) async {
    await Socket.connect(ip, 81, timeout: timeout).then((socket) {
      socket.destroy();
      callback(ip);
      print("Found: $ip");
      return true;
    }).catchError((error) {});
    return false;
  }
}

class WebsocketList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return Text("$index");
    });
  }
}
