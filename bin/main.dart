import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

Future main() async {
  final app = Application<TicTacToeServerChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  await app.startOnCurrentIsolate();

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
