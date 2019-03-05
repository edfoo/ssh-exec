import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:ssh_exec/controls/database_control.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/resources/bloc_base.dart';
import 'package:ssh_exec/events/server_event.dart';

class ServerBloc implements BlocBase {
  static DatabaseControl dbControl = DatabaseControl();

  // Stream to handle server events, e.g. update, edit, remove.
  final StreamController<ServerEvent> _serverEventController =
      StreamController<ServerEvent>.broadcast();
  Sink<ServerEvent> get serverEventSink => _serverEventController.sink;

  // Stream to handle the server state based on events
  // coming into the event stream.
  final BehaviorSubject<Server> _serverController = BehaviorSubject<Server>();
  Sink<Server> get serverSink => _serverController.sink;
  Stream<Server> get serverStream => _serverController.stream;

  // Stream to handle the full list of servers based on
  // events coming into the event stream.
  final StreamController<List<Server>> _serverListController =
      StreamController<List<Server>>();
  Stream<List<Server>> get serverListStream => _serverListController.stream;

  ServerBloc() {
    initBloc();
  }

  Future<void> initBloc() async {

    await dbControl.initDb();

    _serverEventController.stream.listen(_mapEventToState);

    _updateServerListStream();
  }

  Future<void> _mapEventToState(ServerEvent event) async {
    if (event is AddServerEvent) {
      print("[ServerBloc.PrintServerDetails]: Server to add/edit :");
      printServerDetails(event.server);
      // Update the database.
      if (event.server.id == -1) {
        event.server.id = DateTime.now().millisecondsSinceEpoch;
      }
      await dbControl.writeServerToDatabase(event.server);
      // Can't move this command outside the if
      // statement, because otherwise the event's
      // server field is not available.
      await _updateServerStream(event.server);

    } else if (event is RemoveServerEvent) {
      await dbControl.removeServerFromDb(event.server.id);

    } else if (event is ClearDatabaseEvent) {
      await dbControl.clearDb();
    }

    await _updateServerListStream();
  }

  Future<void> _updateServerListStream() async {
    // Get the new list of records (servers) from the database
    // and update the server list stream (for UI update).
    List<Record> _recordList = await dbControl.getAllRecords();
    List<Server> _serverList = convertRecordsToServers(_recordList);
    _serverListController.sink.add(_serverList);
  }

  Future<void> _updateServerStream(Server _s) async {
    _serverController.sink.add(_s);
  }

  List<Server> convertRecordsToServers(List<Record> _recordList) {
    List<Server> _serverList = List<Server>();

    _recordList.toList().forEach((rec) {
      Server _server = Server.initial();
      _server.id = rec.value['id'];
      _server.name = rec.value['name'];
      _server.address = rec.value['address'];
      _server.port = rec.value['port'];
      _server.username = rec.value['username'];
      _server.password = rec.value['password'];
      if (rec.value['commands'] != null) {
        rec.value['commands'].forEach((cmd) {
          _server.commands.add(cmd);
        });
      }
      _serverList.add(_server);
    });
    return _serverList;
  }

  @override
  void dispose() {
    _serverController.close();
    _serverEventController.close();
    _serverListController.close();
  }

  //TODO: Remove this method
  void printServerDetails(Server _s) {
    print(
        '[ServerBloc.PrintServerDetails]: Name: ${_s.name}, ID: ${_s.id}, Address: ${_s.address}');
  }
}
