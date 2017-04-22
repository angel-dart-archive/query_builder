import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder_mongo/query_builder_mongo.dart';

main() async {
  var db = new Db('mongodb://localhost:27017/query_builder_mongo_example');
  await db.open();
  var store = new MongoDataStore(db);

  var grades = store.repository('grades');

  await grades.insertAll([
    {'name': 'Bob', 'score': 35},
    {'name': 'Bob', 'score': 67},
    {'name': 'Sally', 'score': 100}
  ]);

  // Fetch average
  var avg = await grades.all().average('score');
  print('Average score: $avg');

  await store.close();
}
