import 'package:mongo_dart/mongo_dart.dart';
import 'package:mutex/mutex.dart';

class MongoQueryBuilder {
  final ReadWriteMutex mutex;
  final DbCollection collection;
  final SelectorBuilder query;

  MongoQueryBuilder(this.mutex, this.collection, this.query);
}