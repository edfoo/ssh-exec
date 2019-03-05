import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
//import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/models/server.dart';
//import 'package:ssh_exec/models/ssh_response_message.dart';
import 'package:ssh_exec/pages/command_list_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class ServerGridWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServerGridWidgetState();
  }
}

class ServerGridWidgetState extends State<ServerGridWidget> {
  ServerBloc _serverBloc;
  List<Server> _serverList = [Server()];
  //SshBloc _sshBloc;
  @override
  Widget build(BuildContext context) {
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    //_sshBloc = BlocProvider.of<SshBloc>(context);
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
                    //_sshBloc.sshResultsink.add(SshResponseMessage.empty());
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
    //_sshBloc.dispose();
    super.dispose();
  }
}
