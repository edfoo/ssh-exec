import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/pages/command_list_page.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh_exec/events/server_event.dart';

class MainServerGridPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainServerGridPageState();
  }
}

class MainServerGridPageState extends State<MainServerGridPage> {
  ServerBloc _serverBloc;
  List<Server> _serverList = [Server()];
  bool testBool = true;
  @override
  Widget build(BuildContext context) {
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("SSH exec appbar"),
        // actions: <Widget>[
        //   PopupMenuButton(
        //     onSelected: null,
        //     itemBuilder: null,
        //   )
        // ],
      ),
      body: StreamBuilder<List<Server>>(
          initialData: _serverList,
          stream: _serverBloc.serverListStream,
          builder: (context, snapshot) {
            if (snapshot.data.length == 0) {
              return Center(child: Text('No servers in database.'));
            } else {
              return GridView.builder(
                shrinkWrap: true,
                primary: true,
                padding: EdgeInsets.all(1.0),
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  return InkWell(
                    child: makeGridCell(
                      snapshot.data[index].name,
                      Icons.computer,
                    ),
                    onTap: () {
                      print(
                          '[CmdListPage.Edit]: ${snapshot.data[index].name} : ${snapshot.data[index].id} : ${snapshot.data[index].address}');
                      // Update the Server Sink with the server the user tapped on
                      // and navigate to the server's command list page.
                      _serverBloc.serverSink.add(snapshot.data[index]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommandListPage()),
                      );
                    },
                  );
                },
              );
            }
          }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "clear",
            child: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _serverBloc.serverEventSink.add(ClearDatabaseEvent());
              });
            },
          ),
          FloatingActionButton(
            heroTag: "refresh",
            child: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          FloatingActionButton(
              heroTag: "add",
              child: Icon(Icons.add),
              onPressed: () {
                // Push an empty server to the Server Sink
                // and navigate to the page where you
                // can add a server (SubmitServerPage).
                _serverBloc.serverSink.add(Server());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubmitServerPage()),
                );
              }),
        ],
      ),
    );
  }

  Card makeGridCell(String name, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.elliptical(10, 10))),
      elevation: 5.0,
      margin: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Container(child: Center(child: Icon(icon), heightFactor: 2)),
          Container(child: Center(child: Text(name), heightFactor: 0)),
        ],
      ),
    );
  }
}
