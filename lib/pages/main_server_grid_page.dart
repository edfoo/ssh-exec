import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh_exec/widgets/server_grid_widget.dart';

class MainServerGridPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainServerGridPageState();
  }
}

class MainServerGridPageState extends State<MainServerGridPage> {
  ServerBloc _serverBloc;
  bool testBool = true;
  @override
  Widget build(BuildContext context) {
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("SSH exec"),
      ),
      body: ServerGridWidget(),
      floatingActionButton: FloatingActionButton(
          heroTag: "add",
          child: Icon(Icons.add),
          onPressed: () {
            // Push an empty server to the Server Sink
            // and navigate to the page where you
            // can add a server (SubmitServerPage).
            _serverBloc.serverSink.add(Server.initial());
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubmitServerPage()),
            );
          }),
    );
  }
}
