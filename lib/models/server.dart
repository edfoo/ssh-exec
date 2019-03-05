class Server {
  num id, port;
  String name, address, username, password;
  List<String> commands;

  // Server(
  //     {this.id = -1,
  //     this.name = "",
  //     this.address = "",
  //     this.port = 22,
  //     this.username = "",
  //     this.password = "",
  //     this.commands = const []});

  // This constructor is to get a modifiable list
  // of commands.
  Server.initial() {
    this.id = -1;
    this.name = "";
    this.address = "";
    this.port = 22;
    this.username = "";
    this.password = "";
    this.commands = [];
  }

  num get getId => id;
}
