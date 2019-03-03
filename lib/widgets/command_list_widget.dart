import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class CommandListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommandListWidgetState();
  }
}

class CommandListWidgetState extends State<CommandListWidget> {
  ServerBloc _serverBloc;
  Server _server = Server();
  List<String> _cmdList;
  SshBloc _sshBloc;

  @override
  Widget build(BuildContext context) {
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<Server>(
        stream: _serverBloc.serverStream,
        initialData: Server(),
        builder: (context, snapshot) {
          _sshBloc = BlocProvider.of<SshBloc>(context);
          _cmdList = snapshot.data.commands;
          return Container(
            padding: EdgeInsets.all(10),
            height: 235.0,
            child: Card(
              elevation: 20,
              child: (_cmdList.length > 0)
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _cmdList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(3, 3))),
                          elevation: 5.0,
                          margin: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  _sshBloc.sshEventSink.add(
                                      SshExecuteEvent(snapshot.data, index));
                                },
                                child: ListTile(
                                  dense: true,
                                  title: Center(
                                      child:
                                          Text(snapshot.data.commands[index])),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                          'No commands configured for \'${snapshot.data.name}\'.')),
            ),
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
