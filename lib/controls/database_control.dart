/// Yes, there is data duplication between the key
/// and the server id. It simplifies the conversion
/// between Record and Server objects.

import 'dart:io';
import 'dart:async';

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:ssh_exec/models/recent_item.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/storage.dart';
import 'package:ssh_exec/resources/parameters.dart';

class DatabaseControl {
  Database _serverDb;
  String _dbPath;
  DatabaseFactory _dbFactory = databaseFactoryIo;

  String get getDbPath => _dbPath;

  Future<void> initDb() async {
    await Storage.localFile.then((File value) {
      _dbPath = value.path;
    });
    _serverDb = await _dbFactory.openDatabase(_dbPath);
    _serverDb.getStore(Parameters.serverStoreName);
    _serverDb.getStore(Parameters.recentStoreName);
  }

  Future<void> writeServerToDatabase(Server _server) async {
    // Find all records in the database with the same
    // name as the incoming server.
    var finder = Finder(
        filter: Filter.equal('name', _server.name),
        sortOrders: [SortOrder('name')]);
    var records = await _serverDb
        ?.findStore(Parameters.serverStoreName)
        ?.findRecord(finder);
    Store _serverStore = _serverDb.getStore(Parameters.serverStoreName);
    var _serverRecord =
        Record(_serverStore, convertServerToMap(_server), _server.id);
    // If no records exist, add the server, otherwise update the current one.
    if (records == null) {
      await _serverDb.putRecord(_serverRecord);
    } else {
      await _serverDb.putRecord(_serverRecord);
    }
  }

  Future<void> writeRecentToDatabase(RecentItem item) async {
    Store _serverStore = _serverDb.getStore(Parameters.recentStoreName);
    await _serverStore.clear();
    var _serverRecord =
        Record(_serverStore, getServerMapFromRecentItem(item), item.commandIndex);
    await _serverDb.putRecord(_serverRecord);
  }

  Future<List<Record>> getAllServers(String storeName) async {
    List<Record> _recordList;
    var finder = Finder(filter: Filter.matches('name', '.*'));
    await _serverDb?.findStore(storeName)?.findRecords(finder)?.then((recList) {
      _recordList = recList;
    });
    return _recordList;
  }

  Future<bool> contains(String storeName, int key) async {
    return await _serverDb.findStore(storeName).containsKey(key);
  }

  // TODO: remove this method.
  Future<Record> getRecentRecordByKey(num key) async {
    var finder = Finder(filter: Filter.byKey(key));
    Record _recent = await _serverDb.findStore(Parameters.recentStoreName).findRecord(finder);
    return _recent;
  }

  Future<void> removeServerFromDb(num id, String storeName) async {
    await _serverDb?.findStore(storeName)?.delete(id);
  }

  Future<void> clearDb() async {
    await _serverDb.findStore(Parameters.serverStoreName).clear();
    await _serverDb.findStore(Parameters.recentStoreName).clear();
  }

  Future<void> clearStore(String storeName) async {
    await _serverDb.findStore(storeName).clear();
  }

  Future<void> deleteDb() async {
    await Storage.localFile.then((File value) {
      _dbPath = value.path;
    });
    _serverDb = await _dbFactory.deleteDatabase(_dbPath);
  }

  void closeDb() {
    _serverDb.close();
  }

  Map<String, Map<String, dynamic>> convertRecentItemToMap(RecentItem _item) {
    Map<String, Map<String, dynamic>> _recentItemMap = {
      _item.commandIndex.toString() : convertServerToMap(_item.server)
    };
    return _recentItemMap;
  }

  Map<String, dynamic> getServerMapFromRecentItem(RecentItem _item) {
    Map<String, dynamic> _serverMap = {
      "id": _item.server.id,
      "name": _item.server.name,
      "address": _item.server.address,
      "port": _item.server.port,
      "username": _item.server.username,
      "password": _item.server.password,
      "commands": _item.server.commands
    };
    return _serverMap;
  }

  Map<String, dynamic> convertServerToMap(Server server) {
    Map<String, dynamic> _serverMap = {
      "id": server.id,
      "name": server.name,
      "address": server.address,
      "port": server.port,
      "username": server.username,
      "password": server.password,
      "commands": server.commands
    };
    return _serverMap;
  }

  // TODO: remove this method
  Future<void> printAllStoreRecords(String storeName) async {
    var finder = Finder(filter: Filter.byKey('.*'));
    await _serverDb.findStore(storeName).findRecords(finder).then((recList) {
      print('RecList Length: ${recList.length}');
      recList.toList().forEach((rec) {
        print('Server key here!: ${rec.value} (Key: ${rec.key})');
      });
    });
  }

  // TODO: Remove this method
  Future<void> countRecords() async {
    print('[DatabaseControl.countRecords] Reading data from db');
    await _serverDb.count().then((int numRecs) {
      print('[countRecords]: ${numRecs.toString()} records in database.');
    });
  }
}
