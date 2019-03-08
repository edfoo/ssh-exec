/// Defines the different types of event that can be passed to the SSH BloC.

import 'package:ssh_exec/models/server.dart';

abstract class SshEvent {}

class SshConnectEvent extends SshEvent {
}

class SshExecuteEvent extends SshEvent {
  Server server;
  int commandIndex;
  SshExecuteEvent(this.server, this.commandIndex);
}

class SshCancelEvent extends SshEvent {
}