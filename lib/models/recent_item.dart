/// Describes the object that stores the most recent command executed, along with its server.

import 'package:ssh_exec/models/server.dart';

class RecentItem {
  Server server;
  int commandIndex;

  RecentItem(this.server, this.commandIndex);

  RecentItem.empty() {
    server = Server.initial();
    commandIndex = -1;
  }
}