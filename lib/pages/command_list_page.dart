/// Page that displays the currently selected server with all its commands.

import 'package:flutter/material.dart';

import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh_exec/widgets/command_list_view.dart';
import 'package:ssh_exec/widgets/dialogs.dart';
import 'package:ssh_exec/widgets/ssh_response_view.dart';

class CommandListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommandListPageState();
  }
}

class CommandListPageState extends State<CommandListPage> {
  ServerBloc _serverBloc;
  SshBloc _sshBloc;
  Server _server = Server.initial();
  bool cancelled = false;

  @override
  Widget build(BuildContext context) {
    _sshBloc = BlocProvider.of<SshBloc>(context);
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<Server>(
        initialData: _server,
        stream: _serverBloc.serverStream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Edit Button in Application Bar
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubmitServerPage()));
                  },
                ),
                // Delete button in Application Bar
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    confirmDelete(context, snapshot.data);
                  },
                )
              ],
            )),
            body: Column(
              children: <Widget>[
                Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(10.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(3, 3))),
                    child: ListTile(
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                              child: Text(
                            snapshot.data.name,
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic),
                          )),
                          Center(
                              child: Text(snapshot.data.address,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic))),
                        ],
                      ),
                      trailing: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.do_not_disturb_alt),
                            onPressed: () {
                              _sshBloc.sshEventSink.add(SshCancelEvent());
                            },
                          ),
                          Text('Disconnect')
                        ],
                      ),
                    )),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      CommandListView(),
                      SshResponseView(),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  confirmDelete(BuildContext context, Server server) async {
    final dialogResponse = await Dialogs.confirm(context, 'Confirm delete',
        'Are you sure you want permanently remove server \'${server.name}\'?');
    if (dialogResponse == DialogAction.yes) {
      _serverBloc.serverEventSink.add(RemoveServerEvent(server));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    cancelled = true;
    _sshBloc?.sshEventSink?.add(SshCancelEvent());
    super.dispose();
  }
}
