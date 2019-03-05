import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/storage.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh_exec/resources/parameters.dart';
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
        actions: <Widget>[
          // Save Button
          PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: menuAction,
              itemBuilder: (context) {
                return Parameters.menuList.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              })
        ],
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

  void menuAction(String menuItem) async {
    String fullPath;
    await Storage.localFile.then((File value) {
      fullPath = value.path;
    });
    if (menuItem == Parameters.showPath) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete server?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text('Database path:\n$fullPath')],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          });
    }
  }
}
