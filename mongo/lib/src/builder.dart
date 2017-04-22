import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

class MongoQueryBuilder {
  final DbCollection collection;
  SelectorBuilder _query;

  SelectorBuilder get query => _query ?? (_query = where.exists('_id'));

  MongoQueryBuilder(this.collection, this._query);
}

class MongoSingleQueryBuilder {
  final DbCollection collection;
  final SelectorBuilder query;

  Future<Map<String, dynamic>> get() => collection.findOne(query);

  MongoSingleQueryBuilder(this.collection, this.query);
}
