import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder/query_builder.dart';
import 'package:query_builder_mongo/query_builder_mongo.dart';

main() async {
  var db = new Db('mongodb://localhost:27017/query_builder_mongo_example');
  await db.open();
  var store = new MongoDataStore(db);

  var grades = store.repository('grades');

  // Detailed results on multiple insertion
  await grades.insertAll([
    {'name': 'Bob', 'score': 35},
    {'name': 'Bill', 'score': 67},
    {'name': 'Sally', 'score': 100}
  ]);

  var smartest =
      await grades.all().orderBy('score', OrderBy.DESCENDING).first().get();
  print('Smartest student: ${smartest['name']}');

  // Get min
  var min = await grades.all().min('score');
  print('Lowest score: $min');

  // Get max
  var max = await grades.all().max('score');
  print('Highest score: $max');

  // Fetch average
  var avg = await grades.all().average('score');
  print('Average score: $avg');

  // Delete everything
  var deletion = await grades.deleteAll();
  print('Deletion successful? ${deletion.successful}');

  await store.close();
}
