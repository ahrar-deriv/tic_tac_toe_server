import 'dart:async';
import 'package:conduit/conduit.dart';   

class Migration4 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("_Todo", "createdAt");
		database.deleteColumn("_Todo", "updatedAt");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    