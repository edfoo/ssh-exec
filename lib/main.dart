import 'package:flutter/material.dart';

import 'package:ssh_exec/blocs/server_bloc.dart';
import 'package:ssh_exec/blocs/ssh_bloc.dart';
import 'package:ssh_exec/pages/main_server_grid_page.dart';
import 'package:ssh_exec/resources/bloc_provider.dart';

// TODO: Encrypt database.


void main() => runApp(SshExecApp());

class SshExecApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: ServerBloc(),
      child: BlocProvider(
        bloc: SshBloc(),
        child: MaterialApp(
          title: 'SSH Exec',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MainServerGridPage())
      ),
    );
  }
}