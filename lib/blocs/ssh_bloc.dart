import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:ssh/ssh.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/ssh_response_message.dart';
import 'package:ssh_exec/resources/bloc_base.dart';
import 'package:flutter/services.dart';

class SshBloc implements BlocBase {
  StreamSubscription _cmdStreamSubscription;
  SSHClient _client;
  SshResponseMessage _myResponse = SshResponseMessage.empty();

// Stream to handle incoming event (execute, cancel)
  final StreamController<SshEvent> _sshEventController =
      StreamController<SshEvent>();
  Sink<SshEvent> get sshEventSink => _sshEventController.sink;

// Stream to handle output from SSH commands to update UI
  final BehaviorSubject<SshResponseMessage> _sshResultStream = BehaviorSubject<SshResponseMessage>();
  Stream<SshResponseMessage> get sshResultStream => _sshResultStream.stream;
  Sink<SshResponseMessage> get sshResultsink => _sshResultStream.sink;

  SshBloc() {
    _sshEventController.stream.listen(_mapEventToResult);
  }

  void _mapEventToResult(SshEvent event) {
    if (event is SshExecuteEvent) {
      print('[EXECUTE EVENT RECEIVED]');
      _runCommand(event.server, event.commandIndex);
    } else if (event is SshCancelEvent) {
      print('[CANCEL EVENT RECEIVED]');
      _cancelCommand();
    }
  }

  void _runCommand(Server _s, int _index) async {
    _client = new SSHClient(
      host: _s.address,
      port: _s.port,
      username: _s.username,
      passwordOrKey: _s.password,
    );

    _setResponse('Connecting to server...', false);

    try {
      String reply = await _client.connect();
      if (reply == "session_connected") {
        _setResponse('Running command...', false);
        _cmdStreamSubscription = _client
            .execute(_s.commands[_index])
            .asStream()
            .listen((commandOutput) {
          if (commandOutput == "") { 
            _setResponse('Command response empty', true);
          } else {
            print('[RESULT]: $commandOutput');
            _setResponse(commandOutput, true);
          }
        });
      } else {
        print('REPLY : $reply');
        _setResponse('Connection failed.', true);
      }
    } on PlatformException catch (e) {
      _setResponse('${e.code}\nError:${e.message}', true);
    } catch (e) {
      _setResponse('${e.message}', true);
    }
  }

  void _setResponse(String _str, bool _isFinal) {
    _myResponse.responseString = _str;
    _myResponse.isfinalMessage = _isFinal;
    _sshResultStream.add(_myResponse);
  }

  void _cancelCommand() {
    _sshResultStream.close();
  }

  @override
  void dispose() {
    _sshEventController.close();
    _sshResultStream.close();
  }
}
