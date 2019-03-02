import 'package:flutter/material.dart';

import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/pages/main_server_grid_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

// TODO: Add confirmation dialog to server delete operation.
// TODO: Move ssh_client to BloC??
// TODO: Encrypt database.
// TODO: Remove Terminal option
// TODO: Add settings menu to 'Clear database', 'Set database password' etc.
// TODO: Add 'Recent' command to MainServerGridPage.


void main() => runApp(SshExecApp());

class SshExecApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: ServerBloc(),
      child: MaterialApp(
          title: 'SSH exec',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MainServerGridPage()),
    );
  }
}