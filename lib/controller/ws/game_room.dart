import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/model/user.dart';

class Player {
  Player({required this.socket, required this.user});

  User user;
  WebSocket socket;
}

class GameRoom {
  GameRoom(this.broadcastSink) {
    const json = JsonCodec();
    const utf8 = Utf8Codec();
    messageCodec = json.fuse(utf8);
  }

  Sink<dynamic> broadcastSink;
  late Codec messageCodec;
  List<Player> players = [];

  void add({required WebSocket socket, required User user}) {
    final player = Player(socket: socket, user: user);
    socket.listen((message) {
      final payload = messageCodec.decode(message);
      handleMessage(payload as Map<String, dynamic>, from: player);
    }, cancelOnError: true);

    players.add(player);
    socket.done.then((_) {
      players.remove(player);
    });
  }

  void handleMessage(Map<String, dynamic> payload, {required Player from}) {
    final event = payload["event"];
    switch (event) {
      case "ping":
        {
          from.socket.add(messageCodec.encode({"event": "pong"}));
        }
        break;
      case "users":
        {
          from.socket.add(messageCodec.encode({
            "event": "users",
            "data": players.map((c) => c.user.username).toList(),
          }));
        }
        break;
      case "message":
        {
          sendMessage(payload["data"] as String, from: from);
        }
        break;

      default:
        {
          from.socket.add(messageCodec
              .encode({"event": "error", "data": "unknown command '$event'"}));
        }
    }
  }

  void sendMessage(String message, {required Player from}) {
    final List<int> bytes = messageCodec.encode(
            {"event": "message", "data": "${from.user.username}: $message"})
        as List<int>;

    sendBytesToAllConnections(bytes);
    sendBytesToOtherIsolates(bytes);
  }

  void sendBytesToAllConnections(List<int> bytes) {
    players.forEach((c) {
      c.socket.add(bytes);
    });
  }

  void sendBytesToOtherIsolates(List<int> bytes) {
    broadcastSink.add({"event": "broadcast", "data": bytes});
  }
}
