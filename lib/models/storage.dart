/// Static class that provides access to the device's local storage.

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:ssh_exec/resources/parameters.dart';

class Storage {
  static Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get localFile async {
    final path = await localPath;
    String filename = Parameters.dbFileName;
    return File('$path/$filename');
  }
  
}
