import 'dart:io';
import 'dart:async';

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/storage.dart';

class DatabaseControl {
  Database serverDb;
  String dbPath;
  DatabaseFactory dbFactory = databaseFactoryIo;

  String get getDbPath => dbPath;

  Future<void> initDb() async {
    await Storage.localFile.then((File value) {
      dbPath = value.path;
    });
    serverDb = await dbFactory.openDatabase(dbPath);
  }

  Future<void> deleteDb() async {
    print('Removing database');
    await Storage.localFile.then((File value) {
      dbPath = value.path;
    });
    serverDb = await dbFactory.deleteDatabase(dbPath);
  }

  Future<void> writeServerToDatabase(Server _server) async {
    // Find all records in the database with the same
    // name as the incoming server.
    var finder = Finder(
        filter: Filter.equal('name', _server.name),
        sortOrders: [SortOrder('name')]);
    var records = await serverDb.findRecord(finder);

    // Yes, there is data duplicattion between the key
    // and the server id. It simplifies the conversion
    // between Record and Server objects.

    // If no records exist, add the server.
    if (records == null) {
      print('[DatabaseControl.writeServerToDatabase] Adding server.');
      await serverDb.put(convertServerToMap(_server), _server.id);
    }
    // A record exists, so update the server in the database.
    else {
      print('id before update: ${_server.id.toString()}');
      print('[DatabaseControl.writeServerToDatabase] Updating server.');
      await serverDb.update(convertServerToMap(_server), _server.id);
    }
    //await countRecords();
    //printAllRecords();
    //clearDb();
  }

  // TODO: remove this method
  Future<void> printAllRecords() async {
    print('[Entering printAllRecords]');
    var finder = Finder(filter: Filter.matches('name', '.*'));
    await serverDb.findRecords(finder).then((recList) {
      recList.toList().forEach((rec) {
        print('Server name: ${rec.value['name']}\nwith Key: ${rec.key}');
        rec.value['commands'].forEach((cmd) {
          print(cmd.toString());
        });
      });
    });
  }

  Future<List<Record>> getAllRecords() async {
    List<Record> _recordList;
    var finder = Finder(filter: Filter.matches('name', '.*'));
    await serverDb?.findRecords(finder)?.then((recList) {
      _recordList = recList;
    });
    return _recordList;
  }

  writeTest() {
    print('[DatabaseControl.writeTest] Writing data to db');
  }

  Future<void> countRecords() async {
    print('[DatabaseControl.countRecords] Reading data from db');
    await serverDb.count().then((int numRecs) {
      print('[countRecords]: ${numRecs.toString()} records in database.');
    });
  }

  Future<void> clearDb() async {
    print('[DatabaseControl.clearDb] : Supposed to clear the database...');
    await serverDb.clear();
  }

  Map convertServerToMap(Server server) {
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

  Future<void> removeServerFromDb(num id) async {
    print('id received: $id');
    await serverDb.delete(id);
  }

  Future<void> removeAllServersfromDb() async {
    // Todo: implement removeAllServersFromDb
  }

  void closeDb() {
    serverDb.close();
  }
}
