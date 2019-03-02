import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/pages/submit_server_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter/services.dart';

class CommandListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommandListPageState();
  }
}

class CommandListPageState extends State<CommandListPage> {
  ServerBloc _serverBloc;
  Server _server = Server();
  List<String> _cmdList;
  StreamSubscription _cmdStreamSubscription;
  TextEditingController _terminalController = TextEditingController();
  TextEditingController _updateController = TextEditingController();
  SSHClient _client;
  bool _isBusyConnecting = false;
  bool cancelled = false;

  @override
  Widget build(BuildContext context) {
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
                    _serverBloc.serverEventSink
                        .add(RemoveServerEvent(snapshot.data));
                    Navigator.pop(context);
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
                              _cancelConnection();
                            },
                          ),
                          Text('Disconnect')
                        ],
                      ),
                    )),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 235.0,
                        child: Card(
                          elevation: 20,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _cmdList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(3, 3))),
                                elevation: 5.0,
                                margin: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  verticalDirection: VerticalDirection.down,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        if (!_isBusyConnecting) {
                                          _terminalController?.clear();
                                          _updateController?.clear();
                                          cancelled = false;
                                          _runCommand(snapshot.data, index);
                                        }
                                      },
                                      child: ListTile(
                                        dense: true,
                                        title: Center(
                                            child: Text(
                                                snapshot.data.commands[index])),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: _isBusyConnecting == false
                              ? TextField(
                                  controller: _terminalController,
                                  enabled: false,
                                  maxLines: null,
                                  scrollPadding: EdgeInsets.all(10),
                                  decoration:null,
                                )
                              : ListTile(
                                  title: TextField(
                                    controller: _updateController,
                                    enabled: false,
                                    scrollPadding: EdgeInsets.all(10),
                                    decoration: null,
                                  ),
                                  trailing: CircularProgressIndicator(),
                                ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _runCommand(Server _s, int _index) async {
    // Create the client object
    _client = new SSHClient(
      host: _s.address,
      port: _s.port,
      username: _s.username,
      passwordOrKey: _s.password,
    );

    // Update the UI with progressindicator.
    _loadProgressIndicator("Connecting to server...");

    try {
      String reply = await _client.connect();
      // Upon successful connection, open a shell
      // to receive response from the server.
      if (reply == "session_connected") {
        if (!cancelled) {
          _loadProgressIndicator("Running command...");
          // Convert the .execute function's Future response
          // to a stream in order to cancel the stream if
          // the uses presses 'Disconnect' or 'Back'.
          _cmdStreamSubscription = _client
              .execute(_s.commands[_index])
              .asStream()
              .listen((commandOutput) {
            if (!cancelled) {
              if (commandOutput == "") {
                _cancelProgressIndicator("Command response empty");
              } else {
                _cancelProgressIndicator(commandOutput);
              }
            } else {
              print('Still going/n$commandOutput');
            }
          });
        } else {
          await _cmdStreamSubscription?.cancel();
        }
      } else {
        print('REPLY : $reply');
        _cancelProgressIndicator("Connection failed.");
      }
    } on PlatformException catch (e) {
      // This is the error thrown by the plugin when
      // it is unable to connect to the server.
      print('[FINALLY] ${e.toString()}');
      if (!cancelled) {
        _connectionFailed('${e.code}\nError:${e.message}');
      }
    } catch (e) {
      print('[Exception in runCommmand]: ${e.message}');
    }
  }

  void _connectionFailed(String msg) {
    _cancelProgressIndicator(msg);
    setState(() {
      if (_terminalController != null) {
        _terminalController?.text = msg;
      }
    });
  }

  // User pressed disconnect.
  void _cancelConnection() async {
    cancelled = true;
    if (_isBusyConnecting) {
      _cancelProgressIndicator("Connection cancelled.");
    } else {
      _cancelProgressIndicator("No connection in progress.");
    }
    await _cmdStreamSubscription?.cancel();
  }

  void _loadProgressIndicator(String msg) {
    if (_updateController != null) {
      setState(() {
        _isBusyConnecting = true;
        _updateController?.text = msg;
      });
    }
  }

  void _cancelProgressIndicator(String msg) {
    setState(() {
      _isBusyConnecting = false;
      _terminalController?.text = msg;
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
