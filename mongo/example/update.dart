import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder_mongo/query_builder_mongo.dart';

main() async {
  var db = new Db('mongodb://localhost:27017/query_builder_mongo_example');
  await db.open();
  var store = new MongoDataStore(db);

  var books = store.repository('todos');


  // Detailed creation results
  var creation = await books.insert({
    'title': 'War and Peace'
  });

  var title = creation.insertedItems.first['title'] as String;
  print('Initial title: $title');

  var update = await books.find(creation.insertedIds.first).update({
    'title': 'Pride and Prejudice'
  });

  title = update.updatedItems.first['title'];
  print('New title: $title');

  // Delete everything
  var deletion = await books.deleteAll();
  print('Deletion successful? ${deletion.successful}');

  await store.close();
}
