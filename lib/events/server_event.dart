/// Defines the different types of event that can be passed to the Server BloC.

import 'package:ssh_exec/models/server.dart';

abstract class ServerEvent {}

class AddServerEvent extends ServerEvent {
  Server server;
  AddServerEvent(this.server);
}

class RemoveServerEvent extends ServerEvent {
  Server server;
  RemoveServerEvent(this.server);
}

class ClearDatabaseEvent extends ServerEvent {}

class RemoveDatabaseEvent extends ServerEvent {}

class AddRecentCommandEvent extends ServerEvent {
  Server server;
  int commandIndex;
  AddRecentCommandEvent(this.server, this.commandIndex);
}