import 'dart:async';

import 'package:ssh_exec/controls/database_control.dart';
import 'package:ssh_exec/models/server.dart';

class ServerState {
  Server currentServer = Server();
  List<Server> serverList;
  DatabaseControl dbControl; // = DatabaseControl();

  ServerState() {
//    initialise();
  }

  void initialise() async {
    // _serverList = await dbControl
    //     .fetchAllServersFromDb()
    //     .then((List<Server> value) {
    //   _serverList = value;
    //   print('[ServerState.initialise]: $_serverList');
    // });
    // addServerToDb(Server());
    //readServerListFromDb();
  }

  Future<List<Server>> get getServerList async => serverList;

  Future<Server> get getServer async => currentServer;
}
