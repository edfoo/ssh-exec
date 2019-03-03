import 'package:flutter/material.dart';
import 'package:ssh_exec/models/ssh_response_message.dart';


class SshResponseWidget extends StatelessWidget {
  final Stream<dynamic> _sshResponseStream;

  SshResponseWidget(this._sshResponseStream);

  @override
  Widget build(BuildContext context) {
    TextEditingController _updateController = TextEditingController();

    return StreamBuilder<SshResponseMessage>(
        stream: _sshResponseStream,
        initialData: SshResponseMessage.empty(),
        builder: (context, snapshot) {
          _updateController.text = snapshot.data.responseString;
          return Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                  child: snapshot.data.isfinalMessage
                      ? TextField(
                          controller: _updateController,
                          enabled: false,
                          maxLines: null,
                          scrollPadding: EdgeInsets.all(10),
                          decoration: null,
                        )
                      : ListTile(
                          title: TextField(
                            controller: _updateController,
                            enabled: false,
                            scrollPadding: EdgeInsets.all(10),
                            decoration: null,
                          ),
                          trailing: CircularProgressIndicator(),
                        )));
        });
  }
}
