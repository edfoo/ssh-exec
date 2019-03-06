import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/pages/command_list_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class ServerGridView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServerGridViewState();
  }
}

class ServerGridViewState extends State<ServerGridView> {
  ServerBloc _serverBloc;
  List<Server> _serverList = [Server.initial()];
  @override
  Widget build(BuildContext context) {
    print('[Entering ServerGridView builder');
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<List<Server>>(
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
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) {
                return InkWell(
                  child: makeGridCell(
                    snapshot.data[index].name,
                    Icons.computer,
                  ),
                  onTap: () {
                    print(
                        '[CmdListPage.Edit]: ${snapshot.data[index].name} : ${snapshot.data[index].id} : ${snapshot.data[index].address}');
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
        });
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

  @override
  void dispose() {
    super.dispose();
  }
}
