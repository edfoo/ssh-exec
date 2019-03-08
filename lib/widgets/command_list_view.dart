import 'package:flutter/material.dart';
import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/events/server_event.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class CommandListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommandListViewState();
  }
}

class CommandListViewState extends State<CommandListView> {
  ServerBloc _serverBloc;
  List<String> _cmdList;
  SshBloc _sshBloc;
  bool isBusyconnecting = true;

  @override
  Widget build(BuildContext context) {
    print('[Entering CommandListView builder');
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<Server>(
        stream: _serverBloc.serverStream,
        initialData: Server.initial(),
        builder: (context, snapshot) {
          _sshBloc = BlocProvider.of<SshBloc>(context);
          _cmdList = snapshot.data.commands;
          return Container(
            padding: EdgeInsets.all(10),
            height: calculateCommandBoxHeight(_cmdList.length.toDouble()),
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
                          margin: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  _sshBloc.sshEventSink.add(
                                      SshExecuteEvent(snapshot.data, index));
                                      _serverBloc.serverEventSink.add(AddRecentCommandEvent(snapshot.data, index));
                                },
                                child: ListTile(
                                  dense: true,
                                  title: Center(
                                      child:
                                          Text(snapshot.data.commands[index],maxLines: 2,
                    overflow: TextOverflow.ellipsis)),
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

  double calculateCommandBoxHeight(double numCommands) {
    double paddingSize = 20 - (7 * (numCommands - 1));
    double boxHeight = paddingSize + (numCommands * 77);
    if (boxHeight > 235) {
      boxHeight = 235;
    }
    return boxHeight;
  }
}
