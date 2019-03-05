import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/ssh_response_message.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter/services.dart';
import 'package:ssh_exec/widgets/command_list_widget.dart';
import 'package:ssh_exec/widgets/ssh_response_widget.dart';

class CommandListPageBloc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommandListPageBlocState();
  }
}

class CommandListPageBlocState extends State<CommandListPageBloc> {
  ServerBloc _serverBloc;
  SshBloc _sshBloc;
  Server _server = Server();
  List<String> _cmdList;
  StreamSubscription _cmdStreamSubscription;
  TextEditingController _terminalController = TextEditingController();
  TextEditingController _updateController = TextEditingController();
  bool cancelled = false;

  @override
  Widget build(BuildContext context) {
    _sshBloc = BlocProvider.of<SshBloc>(context);
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<Server>(
        initialData: _server,
        stream: _serverBloc.serverStream,
        builder: (context, snapshot) {
          _cmdList = snapshot.data.commands;
          return Scaffold(
            appBar: AppBar(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Edit Button in Application Bar
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to the SubmitServerPage so the user
                    // can edit the server. The correct server is
                    // already in the Server Sink stream.
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
                    return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete server?'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                      'Are you sure you want permanently remove server \'${snapshot.data.name}\'')
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  _serverBloc.serverEventSink
                                      .add(RemoveServerEvent(snapshot.data));
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text('Yes'),
                              ),
                              FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              )
                            ],
                          );
                        });
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
                              //_cancelConnection();
                            },
                          ),
                          Text('Disconnect')
                        ],
                      ),
                    )),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      CommandListWidget(),
                      SshResponseWidget(),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    cancelled = true;
    _cmdStreamSubscription?.cancel();
    _terminalController?.dispose();
    _updateController?.dispose();
    super.dispose();
  }
}
