// CounterEvent is a class because most of the time you want to
// pass some data along with the event.
// For example query string to search for in a database.
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