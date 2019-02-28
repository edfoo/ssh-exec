# ssh_exec

Flutter project to SSH into a server and execute a command.

## Installation

Download or clone the repository and open it with your editor of choice. I used Visual Studio Code.

## Libraries

This project uses the following flutter plugins / libraries :
[sembast](https://pub.dartlang.org/packages/sembast) database for storage.
[flutter_ssh](https://pub.dartlang.org/packages/ssh) for SSH communication.

## App limitations
- No interactive terminal.
- No reponse from server until the command terminates.

## TODO:

- Fix CommandListPage bottom container scrolling out of view.
- Fix SubmitServerPage scrolling issue (you have to scroll using the top container).
- Add confirmation dialog to server delete operation.
- Move ssh_client to BloC??
- Encrypt database.
- Remove Terminal option
- Add settings menu to 'Clear database', 'Set database password' etc.
- Add 'Recent' command to MainServerGridPage.
