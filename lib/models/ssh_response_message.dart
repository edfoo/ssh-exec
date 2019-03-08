/// Describes the object that stores a response from the SSH server.

class SshResponseMessage {
  bool isfinalMessage;
  String responseString;

  SshResponseMessage(this.responseString, this.isfinalMessage);

  SshResponseMessage.empty() {
    isfinalMessage = true;
    responseString = "";
  }

}