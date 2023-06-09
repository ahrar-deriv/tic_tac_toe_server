import 'package:tic_tac_toe_server/model/user.dart';
import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class IdentityController extends ResourceController {
  IdentityController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIdentity() async {
    final q = Query<User>(context)
      ..where((u) => u.id).equalTo(request!.authorization!.ownerID);

    final u = await q.fetchOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }
}
