import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:ssh/ssh.dart';
import 'package:ssh_exec/events/ssh_event.dart';
import 'package:ssh_exec/models/server.dart';
import 'package:ssh_exec/models/ssh_response_message.dart';
import 'package:ssh_exec/resources/bloc_base.dart';
import 'package:flutter/services.dart';

class SshBloc implements BlocBase {
  SSHClient _client;
  SshResponseMessage _myResponse = SshResponseMessage.empty();
  bool _isBusyConnecting = false;
  bool _cancelled = false;
  StreamSubscription _connectionSubscription;

// Stream to handle incoming event (execute, cancel)
  final StreamController<SshEvent> _sshEventController =
      StreamController<SshEvent>();
  Sink<SshEvent> get sshEventSink => _sshEventController.sink;

// Stream to handle output from SSH commands to update UI
  final BehaviorSubject<SshResponseMessage> _sshResultStream =
      BehaviorSubject<SshResponseMessage>();
  Stream<SshResponseMessage> get sshResultStream => _sshResultStream.stream;
  Sink<SshResponseMessage> get sshResultsink => _sshResultStream.sink;

  SshBloc() {
    _sshEventController?.stream?.listen(_mapEventToResult);
  }

  void _mapEventToResult(SshEvent event) {
    if (event is SshExecuteEvent) {
      if (!_isBusyConnecting) {
        _cancelled = false;
        _run(event.server, event.commandIndex);
      } else {
        print('Connection already in progress');
      }
    } else if (event is SshCancelEvent) {
      _disconnect();
    }
  }

  void _run(Server _s, int _index) async {
    _isBusyConnecting = true;
    _createClient(_s, _index);
    _connectionSubscription = _connect(_s, _index).asStream().listen((reply) {
      if (!_cancelled) {
        _setResponse(reply, true);
      }
    });
  }

  void _createClient(Server _s, int _index) async {
    _client = new SSHClient(
      host: _s.address,
      port: _s.port,
      username: _s.username,
      passwordOrKey: _s.password,
    );
  }

  Future<String> _connect(Server _s, int _index) async {
    _setResponse('Connecting to server...', false);
    String reply;
    String _commandOutput;

    try {
      reply = await _client.connect();
      if (reply == "session_connected") {
        if (!_cancelled) {
          _setResponse('Running command...', false);
          _commandOutput = await _client.execute(_s.commands[_index]);
          if (_commandOutput == '') {
            reply = ('Command response empty.');
          } else {
            reply = _commandOutput;
          }
        }
      } else {
        reply = ('Connection failed : $reply');
      }
    } on PlatformException catch (e) {
      reply = ('Error : ${e.code}\nError:${e.message}');
    } catch (e) {
      reply = ('Error : ${e.message}');
    }
    _isBusyConnecting = false;
    return reply;
  }

  void _disconnect() async {
    _cancelled = true;
    await _connectionSubscription?.cancel();
    if (_isBusyConnecting) {
      _setResponse("Disconnected.", true);
    }
    _isBusyConnecting = false;
  }

  void _setResponse(String _str, bool _isFinal) {
    _myResponse.responseString = _str;
    _myResponse.isfinalMessage = _isFinal;
    sshResultsink?.add(_myResponse);
    if (_isFinal) {
      _isBusyConnecting = false;
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _sshEventController?.close();
    _sshResultStream?.close();
    _sshEventController?.close();
  }
}
