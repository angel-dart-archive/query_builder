import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:mutex/mutex.dart';
import 'package:query_builder/query_builder.dart';
import 'builder.dart';
import 'repository_query.dart';

// TODO: Add change event support
class MongoRepository extends Repository<Map<String, dynamic>> {
  final StreamController<ChangeEvent<Map<String, dynamic>>> _changes =
      new StreamController<ChangeEvent<Map<String, dynamic>>>.broadcast();
  final mgo.DbCollection _collection;
  final ReadWriteMutex _mutex = new ReadWriteMutex();

  MongoRepository(this._collection);

  @override
  RepositoryQuery<Map<String, dynamic>> all() {
    return new MongoRepositoryQuery(
        new MongoQueryBuilder(_mutex, _collection, null));
  }

  @override
  Future<InsertionResult> insert(data) async {
    var id = _items.length;
    Map<String, dynamic> item = {}
      ..addAll(data)
      ..['id'] = id;
    _items[id] = item;

    return new InsertionResult(1, true, createdIds: [id], createdItems: [item]);
  }

  @override
  Future<InsertionResult> insertAll(Iterable data) async {
    var createdIds = <String>[], createdItems = <Map<String, dynamic>>[];

    for (Map<String, dynamic> datum in data) {
      var id = _items.length;
      Map<String, dynamic> item = {}
        ..addAll(datum)
        ..['id'] = id;
      _items[id] = item;
    }

    return new InsertionResult(createdItems.length, true,
        createdIds: createdIds, createdItems: createdItems);
  }

  @override
  RepositoryQuery<Map<String, dynamic>> raw(query) {
    throw new UnimplementedError('MapRepository does not support raw queries.');
  }
}
