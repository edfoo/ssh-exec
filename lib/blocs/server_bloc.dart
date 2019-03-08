import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:ssh_exec/controls/database_control.dart';
import 'package:ssh_exec/models/recent_item.dart';
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
  final StreamController<RecentItem> _recentController =
      BehaviorSubject<RecentItem>();
  Sink<RecentItem> get _recentSink => _recentController.sink;
  Stream<RecentItem> get recentStream => _recentController.stream;

  ServerBloc() {
    _initBloc();
  }

  Future<void> _initBloc() async {
    await dbControl.initDb();
    _serverEventController.stream.listen(_mapEventToState);
    _updateServerListStream();
    _updateRecentStream();
  }

  Future<void> _mapEventToState(ServerEvent event) async {
    if (event is AddServerEvent) {
      if (event.server.id == -1) {
        event.server.id = DateTime.now().millisecondsSinceEpoch;
      }
      await dbControl.writeServerToDatabase(event.server);
      await _updateServerStream(event.server);
    } else if (event is RemoveServerEvent) {
      await dbControl.removeServerFromDb(
          event.server.id);
    } else if (event is ClearDatabaseEvent) {
      await dbControl.clearDb();
    } else if (event is RemoveDatabaseEvent) {
      await dbControl.deleteDb();
      await dbControl.initDb();
    } else if (event is AddRecentCommandEvent) {
      RecentItem _recentItem = RecentItem(event.server, event.commandIndex);
      await dbControl.writeRecentToDatabase(_recentItem);
      _recentSink.add(_recentItem);
    }

    await _updateServerListStream();
    await _updateRecentStream();
  }

  Future<void> _updateServerListStream() async {
    List<Record> _recordList =
        await dbControl?.getAllServers(Parameters.serverStoreName);
    List<Server> _serverList = convertRecordsToServers(_recordList);
    _serverListController?.sink?.add(_serverList);
  }

  Future<void> _updateRecentStream() async {
    List<Record> _recordList =
        await dbControl?.getAllServers(Parameters.recentStoreName);
    if (_recordList.isNotEmpty) {
      Record _recentRecord = _recordList.first;
      bool contains = await dbControl.contains(
          Parameters.serverStoreName, _recentRecord.value['id']);
      if (contains) {
        RecentItem _recentItem = convertRecordToRecentItem(_recentRecord);
        _recentSink.add(_recentItem);
      }
    } else {
      _recentSink.add(RecentItem.empty());
    }
  }

  Future<void> _updateServerStream(Server _server) async {
    _serverController?.sink?.add(_server);
  }

  List<Server> convertRecordsToServers(List<Record> _recordList) {
    List<Server> _serverList = List<Server>();

    _recordList.toList().forEach((_record) {
      Server _server = Server.initial();
      _server = convertRecordToServer(_record);
      _serverList?.add(_server);
    });
    return _serverList;
  }

  Server convertRecordToServer(Record _record) {
    Server _server = Server.initial();
    _server?.id = _record.value['id'];
    _server?.name = _record.value['name'];
    _server?.address = _record.value['address'];
    _server?.port = _record.value['port'];
    _server?.username = _record.value['username'];
    _server?.password = _record.value['password'];
    if (_record?.value['commands'] != null) {
      _record?.value['commands'].forEach((cmd) {
        _server?.commands?.add(cmd);
      });
    }
    return _server;
  }

  Server convertMapToServer(Map<String, dynamic> _map) {
    Server _server = Server.initial();
    _server.id = _map['id'];
    _server.name = _map['name'];
    _server.address = _map['address'];
    _server.port = _map['port'];
    _server.username = _map['username'];
    _server.password = _map['password'];
    _map['commands'].toList().forEach((cmd) {
      _server.commands.add(cmd);
    });
    return _server;
  }

  RecentItem convertRecordToRecentItem(Record _record) {
    return RecentItem(convertMapToServer(_record.value), _record.key);
  }

  @override
  void dispose() {
    _serverController?.close();
    _serverEventController?.close();
    _serverListController?.close();
    _recentController?.close();
  }
}
