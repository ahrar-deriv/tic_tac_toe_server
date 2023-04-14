import 'package:tic_tac_toe_server/model/user.dart';
import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class UserController extends ResourceController {
  UserController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getUsers() async {
    final query = Query<User>(context)
      ..sortBy((u) => u.score, QuerySortOrder.descending);
    return Response.ok(await query.fetch());
  }

  @Operation.get('username')
  Future<Response> getUserByName(@Bind.path('username') String username) async {
    final q = Query<User>(context)..where((o) => o.username).equalTo(username);
    final user = await q.fetchOne();

    if (user == null) {
      return Response.notFound();
    }

    return Response.ok(user);
  }

  Future<User?> getUser(String username) async {
    final q = Query<User>(context)..where((o) => o.username).equalTo(username);
    final user = await q.fetchOne();
    return user;
  }

  Future<User> getUserByOwnerID(int ownerID) async {
    final q = Query<User>(context)..where((o) => o.id).equalTo(ownerID);
    final user = await q.fetchOne();
    return user!;
  }

  @Operation.get('id')
  Future<Response> getUserById(@Bind.path('id') int id) async {
    final q = Query<User>(context)..where((o) => o.id).equalTo(id);
    final user = await q.fetchOne();

    if (user == null) {
      return Response.notFound();
    }

    return Response.ok(user);
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    if (user.username == null || user.password == null) {
      return Response.badRequest(
        body: {"error": "username and password required."},
      );
    }
    if (user.username!.length < 3 || user.password!.length < 3) {
      return Response.badRequest(
        body: {
          "error": "username and password characters must be greater than 3."
        },
      );
    }

    final salt = AuthUtility.generateRandomSalt();
    // final hashedPassword = authServer!.hashPassword(user.password!, salt);
    final hashedPassword =
        AuthUtility.generatePasswordHash(user.password!, salt);

    final query = Query<User>(context)
      ..values = user
      ..values.hashedPassword = hashedPassword
      ..values.salt = salt
      ..values.username = user.username;
    final User u;
    final login = await getUser(user.username!);
    if (login == null) {
      u = await query.insert();
    } else {
      u = login;
    }
    final token = await authServer.authenticate(
      u.username,
      user.password,
      request!.authorization!.credentials!.username,
      request!.authorization!.credentials!.password,
    );
    return AuthController.tokenResponse(token);
  }
}
