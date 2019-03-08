/// Describes the object that stores a server's information.

class Server {
  num id, port;
  String name, address, username, password;
  List<String> commands;

  Server.initial() {
    this.id = -1;
    this.name = "";
    this.address = "";
    this.port = 22;
    this.username = "";
    this.password = "";
    this.commands = [];
  }
}
