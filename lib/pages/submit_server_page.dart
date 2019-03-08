import 'package:flutter/material.dart';

import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class SubmitServerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubmitServerPageState();
  }
}

class SubmitServerPageState extends State<SubmitServerPage> {
  Server _server = Server.initial();
  static final _formKey = GlobalKey<FormState>();
  List<String> _cmdList = List<String>();
  TextEditingController _cmdTextController = TextEditingController();
  bool formIsValid = false;

  @override
  Widget build(BuildContext context) {
    ServerBloc _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<Server>(
        initialData: Server.initial(),
        stream: _serverBloc.serverStream,
        builder: (context, snapshot) {
          // If this is not a new server,
          // copy the commands into _cmdList.
          if (snapshot.data.id != -1) {
            _cmdList = snapshot.data.commands;
          }
          _server.id = snapshot.data.id;
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                // Save Button
                FlatButton(
                  child: Text('Save',
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  textColor: Colors.white,
                  onPressed: () {
                    onSavePressed();
                    if (formIsValid) {
                      _serverBloc.serverEventSink.add(AddServerEvent(_server));
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.computer),
                              title: TextFormField(
                                key: new Key(snapshot.data.name),
                                initialValue: snapshot.data.name,
                                decoration:
                                    InputDecoration(hintText: "Server Name"),
                                validator: (str) {
                                  if (str.isEmpty) {
                                    return "Please enter a server name";
                                  }
                                },
                                onSaved: (str) => _server.name = str,
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_on),
                              title: TextFormField(
                                key: new Key(snapshot.data.address),
                                initialValue: snapshot.data.address,
                                decoration: InputDecoration(
                                    hintText:
                                        "Server address (or domain name)"),
                                onSaved: (str) => _server.address = str,
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.settings_ethernet),
                              title: TextFormField(
                                key: new Key(snapshot.data.port.toString()),
                                initialValue: snapshot.data.port.toString(),
                                decoration: InputDecoration(hintText: "Port"),
                                onSaved: (str) => _server.port = num.parse(str),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.label),
                              title: TextFormField(
                                key: new Key(snapshot.data.username),
                                initialValue: snapshot.data.username,
                                decoration:
                                    InputDecoration(hintText: "Username"),
                                onSaved: (str) => _server.username = str,
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.security),
                              title: TextFormField(
                                key: new Key(snapshot.data.password),
                                initialValue: snapshot.data.password,
                                decoration:
                                    InputDecoration(hintText: "Password"),
                                onSaved: (str) => _server.password = str,
                                obscureText: true,
                              ),
                            ),
                          ],
                        )),
                    ListTile(
                      leading: Icon(Icons.chevron_right),
                      title: TextFormField(
                        controller: _cmdTextController,
                        decoration: InputDecoration(
                            hintText: '{Type command, then press "+"}'),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _addCommand();
                          });
                        },
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cmdList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          selected: true,
                          leading: Icon(Icons.chevron_right),
                          title: TextFormField(
                            enabled: false,
                            decoration:
                                InputDecoration(hintText: '${_cmdList[index]}'),
                            onFieldSubmitted: (value) {
                              setState(() {
                                _cmdList.removeAt(index);
                                _cmdList.insert(index, value);
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever),
                            tooltip: _cmdList[index].toString(),
                            onPressed: () {
                              setState(() {
                                _deleteCommandTile(index);
                              });
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _addCommand() {
    if (_cmdTextController.text.isNotEmpty) {
      _cmdList.add(_cmdTextController.text);
      _cmdTextController.clear();
    }
  }

  void _deleteCommandTile(int index) {
    _cmdList.removeAt(index);
  }

  void onSavePressed() {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _server.commands = _cmdList;
      formIsValid = true;
    }
  }

  @override
  void dispose() {
    _cmdTextController.dispose();
    super.dispose();
  }
}
