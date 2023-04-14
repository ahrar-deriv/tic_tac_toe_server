import 'package:tic_tac_toe_server/controller/user_controller.dart';
import 'package:tic_tac_toe_server/controller/ws/game_room.dart';
import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class WebsocketController extends Controller {
  WebsocketController(
      {required this.room, required this.context, required this.authServer});

  final ManagedContext context;
  final AuthServer authServer;

  final GameRoom room;

  @override
  FutureOr<RequestOrResponse?> handle(Request request) async {
    // ignore: close_sinks
    final socket = await WebSocketTransformer.upgrade(request.raw);
    final forUserID = request.authorization!.ownerID;
    final user =
        await UserController(context, authServer).getUserByOwnerID(forUserID!);
    room.add(socket: socket, user: user);
    return null;
  }
}
