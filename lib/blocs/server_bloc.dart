import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:ssh_exec/controls/database_control.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/resources/bloc_base.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/resources/parameters.dart';

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

  // Stream to handle the most recent command executed.
  final StreamController<Server> _recentController = BehaviorSubject<Server>();
  Sink<Server> get _recentSink => _recentController.sink;
  Stream<Server> get recentStream => _recentController.stream;

  ServerBloc() {
    initBloc();
  }

  Future<void> initBloc() async {
    await dbControl.initDb();
    _serverEventController.stream.listen(_mapEventToState);
    _updateServerListStream();
    _updateRecentStream();
  }

  Future<void> _mapEventToState(ServerEvent event) async {
    if (event is AddServerEvent) {
      // Update the database.
      if (event.server.id == -1) {
        event.server.id = DateTime.now().millisecondsSinceEpoch;
      }
      await dbControl.writeServerToDatabase(event.server);
      await _updateServerStream(event.server);
    } else if (event is RemoveServerEvent) {
      await dbControl.removeServerFromDb(
          event.server.id, Parameters.serverStoreName);
    } else if (event is ClearDatabaseEvent) {
      await dbControl.clearDb();
    } else if (event is RemoveDatabaseEvent) {
      await dbControl.deleteDb();
      await dbControl.initDb();
    } else if (event is AddRecentCommandEvent) {
      await dbControl.writeRecentToDatabase(event.server, event.commandIndex);
      await _updateRecentStream();
    }

    await _updateServerListStream();
  }

  Future<void> _updateServerListStream() async {
    // Get the new list of records (servers) from the database
    // and update the server list stream (for UI update).
    List<Record> _recordList =
        await dbControl?.getAllServers(Parameters.serverStoreName);
    List<Server> _serverList = convertRecordsToServers(_recordList);
    _serverListController?.sink?.add(_serverList);
  }

  Future<void> _updateRecentStream() async {
    List<Record> _recentRecordList = List<Record>();
    List<Server> _recentServerList = List<Server>();
    _recentRecordList = await dbControl?.getAllServers(Parameters.recentStoreName);
    _recentServerList = convertRecordsToServers(_recentRecordList);
    _recentSink.add(_recentServerList.first);
  }

  Future<void> _updateServerStream(Server _s) async {
    _serverController?.sink?.add(_s);
  }

  List<Server> convertRecordsToServers(List<Record> _recordList) {
    List<Server> _serverList = List<Server>();

    _recordList.toList().forEach((rec) {
      Server _server = Server.initial();
      _server?.id = rec.value['id'];
      _server?.name = rec.value['name'];
      _server?.address = rec.value['address'];
      _server?.port = rec.value['port'];
      _server?.username = rec.value['username'];
      _server?.password = rec.value['password'];
      if (rec?.value['commands'] != null) {
        rec?.value['commands'].forEach((cmd) {
          _server?.commands?.add(cmd);
        });
      }
      _serverList?.add(_server);
    });
    return _serverList;
  }

  Server makeCopyWithoutCommands(Server _server, int commandIndex) {
    Server _newServer = Server.initial();
    _newServer?.id = _server?.id;
    _newServer?.address = _server?.address;
    _newServer?.port = _server?.port;
    _newServer?.username = _server?.username;
    _newServer?.password = _server?.password;
    _newServer?.commands?.add(_server?.commands[commandIndex]);
    return _newServer;
  }

  @override
  void dispose() {
    _serverController?.close();
    _serverEventController?.close();
    _serverListController?.close();
  }
}
