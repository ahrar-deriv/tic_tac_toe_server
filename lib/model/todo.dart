import 'package:conduit/conduit.dart';

class Todo extends ManagedObject<_Todo> implements _Todo {}

class _Todo {
  @primaryKey
  int? id;

  String? title;
  String? description;
  bool? completed;
}
