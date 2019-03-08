/// Class that a button with the most recent command executed.

import 'package:flutter/material.dart';

import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/recent_item.dart';
import 'package:ssh_exec/pages/command_list_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

class RecentCommandView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentCommandViewState();
  }
}

class RecentCommandViewState extends State<RecentCommandView> {
  ServerBloc _serverBloc;
  SshBloc _sshBloc;
  bool isBusyconnecting = true;
  String _recentCommand;

  @override
  Widget build(BuildContext context) {
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    return StreamBuilder<RecentItem>(
        stream: _serverBloc.recentStream,
        initialData: RecentItem.empty(),
        builder: (context, snapshot) {
          _sshBloc = BlocProvider.of<SshBloc>(context);
          if (snapshot.data.commandIndex != -1) {
            _recentCommand =
                snapshot.data.server.commands[snapshot.data.commandIndex];
          }
          return Container(
            padding: EdgeInsets.all(10),
            height: 97.0,
            child: (snapshot.data.commandIndex >= 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
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
                                _serverBloc.serverSink
                                    .add(snapshot.data.server);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommandListPage()),
                                );
                                Future.delayed(Duration(seconds: 1)).then((_) {
                                  _sshBloc.sshEventSink.add(SshExecuteEvent(
                                      snapshot.data.server,
                                      snapshot.data.commandIndex));
                                });
                              },
                              child: ListTile(
                                dense: true,
                                title: Center(
                                    child: Text(
                                        '${snapshot.data.server.name}: $_recentCommand',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
                : Center(child: Text('No recent command.')),
          );
        });
  }
}
