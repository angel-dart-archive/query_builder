import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder_mongo/query_builder_mongo.dart';

main() async {
  var db = new Db('mongodb://localhost:27017/query_builder_mongo_example');
  await db.open();
  var store = new MongoDataStore(db);

  var todos = store.repository('todos');
  
  // Easily query as Stream
  var fetched = await todos.all().get().toList();
  print('Found ${fetched.length} todo(s): $fetched');

  // Detailed creation results
  var creation = await todos.insert({
    'foo': 'bar'
  });

  print('Created todo #${creation.insertedIds.first}:');
  print(creation.insertedItems.first);

  // Delete everything
  var deletion = await todos.deleteAll();
  print('Deletion successful? ${deletion.successful}');

  await store.close();
}
