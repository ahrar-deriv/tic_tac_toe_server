import 'package:tic_tac_toe_server/controller/identity_controller.dart';
import 'package:tic_tac_toe_server/controller/todo_controller.dart';
import 'package:tic_tac_toe_server/controller/user_controller.dart';
import 'package:tic_tac_toe_server/model/user.dart';
import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class TicTacToeServerChannel extends ApplicationChannel {
  late ManagedContext context;
  late AuthServer authServer;

  @override
  Future prepare() async {
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final store = PostgreSQLPersistentStore.fromConnectionInfo(
        "dart_app", "dart", "localhost", 5432, "dart_game_db");
    context = ManagedContext(dataModel, store);
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    authServer = AuthServer(ManagedAuthDelegate<User>(context));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    /* OAuth 2.0 Resource Owner Grant Endpoint */
    router.route("/auth/token").link(() => AuthController(authServer));

    /* Create an account */
    router
        .route("/user")
        .link(() => Authorizer.basic(authServer))
        ?.link(() => UserController(context, authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer))
        ?.link(() => IdentityController(context));

    /* Todo routs */
    router.route("/todo/[:id]").link(() => TodoController(context));

    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    return router;
  }
}
