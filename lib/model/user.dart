import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String? password;

  @override
  void willInsert() {
    createdAt = DateTime.now();
  }
}

class _User extends ResourceOwnerTableDefinition {
  @Column()
  int? score = 0;

  DateTime? createdAt;
}
