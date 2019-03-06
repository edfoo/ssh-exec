import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/storage.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh_exec/resources/parameters.dart';
import 'package:ssh_exec/widgets/dialogs.dart';
import 'package:ssh_exec/widgets/recent_command_view.dart';
import 'package:ssh_exec/widgets/server_grid_view.dart';

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
    print('[Entering MainServerGridPage builder');
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
      body: Column(
        children: <Widget>[
          RecentCommandView(),
          ServerGridView(),
        ],
      ),
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
    if (menuItem == Parameters.showPath) {
      String fullPath;
      await Storage.localFile.then((File value) {
        fullPath = value.path;
      });
      return Dialogs().information(context, 'Database file:', fullPath);
    } else if (menuItem == Parameters.clearDB) {
      final dialogResult = await Dialogs.confirm(
          context, 'Confirm clear', 'Remove all servers from database?');
      if (dialogResult == DialogAction.yes) {
        _serverBloc.serverEventSink.add(ClearDatabaseEvent());
      }
    } else if (menuItem == Parameters.removeDB) {
      final dialogResult = await Dialogs.confirm(
        context,
        'Confirm remove',
        'Completely remove database?\n(in case of corruption)',
      );
      if (dialogResult == DialogAction.yes) {
        _serverBloc.serverEventSink.add(RemoveDatabaseEvent());
      }
    }
  }
}
