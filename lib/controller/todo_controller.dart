import 'package:tic_tac_toe_server/model/todo.dart';
import 'package:tic_tac_toe_server/tic_tac_toe_server.dart';

class TodoController extends ResourceController {
  TodoController(this.context);

  ManagedContext context;

  @Operation.get()
  Future<Response> getTodos() async {
    final query = Query<Todo>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.get('id')
  Future<Response> getTodoById(@Bind.path('id') int id) async {
    final q = Query<Todo>(context)..where((o) => o.id).equalTo(id);
    final todo = await q.fetchOne();

    if (todo == null) {
      return Response.notFound();
    }

    return Response.ok(todo);
  }

  @Operation.post()
  Future<Response> createTodo(@Bind.body() Todo inputTodo) async {
    final query = Query<Todo>(context)..values = inputTodo;
    final insertedTodo = await query.insert();

    return Response.ok(insertedTodo);
  }

  @Operation.put('id')
  Future<Response> updateTodo(
      @Bind.path('id') int id, @Bind.body() Todo inputTodo) async {
    final query = Query<Todo>(context)
      ..values = inputTodo
      ..where((o) => o.id).equalTo(id);

    final updatedTodo = await query.updateOne();

    if (updatedTodo == null) {
      return Response.notFound();
    }

    return Response.ok(updatedTodo);
  }

  @Operation.delete('id')
  Future<Response> deleteTodo(@Bind.path('id') int id) async {
    final query = Query<Todo>(context)..where((o) => o.id).equalTo(id);

    final deletedTodo = await query.delete();

    if (deletedTodo == null) {
      return Response.notFound();
    }

    return Response.ok(deletedTodo);
  }
}
