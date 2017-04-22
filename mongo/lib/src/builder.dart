import 'package:mongo_dart/mongo_dart.dart';
import 'package:mutex/mutex.dart';

class MongoQueryBuilder {
  final ReadWriteMutex mutex;
  final DbCollection collection;
  SelectorBuilder _query;

  SelectorBuilder get query => _query ?? (_query = where.exists('_id'));

  MongoQueryBuilder(this.mutex, this.collection, this._query);
}
