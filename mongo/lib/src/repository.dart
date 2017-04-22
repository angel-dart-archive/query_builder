import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:mutex/mutex.dart';
import 'package:query_builder/query_builder.dart';
import 'builder.dart';
import 'repository_query.dart';

// TODO: Add change event support
class MongoRepository extends Repository<Map<String, dynamic>> {
  final StreamController<ChangeEvent<Map<String, dynamic>>> _changes =
      new StreamController<ChangeEvent<Map<String, dynamic>>>.broadcast(
          onListen: () {
    print(
        'NOTE: You called changes() on a MongoRepository, but MongoDB does not send change events. ' +
            'The returned stream will never output any events.');
  });

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() {
    return _changes.stream;
  }

  final mgo.DbCollection _collection;
  final bool _serializeId;
  final ReadWriteMutex _mutex = new ReadWriteMutex();

  MongoRepository(this._collection, this._serializeId);

  Map<String, dynamic> _serialize(Map<String, dynamic> map) {
    if (!_serializeId) return map;

    return map.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var v = map[k];

      if (v is mgo.ObjectId)
        return out..[k] = v.toHexString();
      else if (v is Map<String, dynamic>)
        return out..[k] = _serialize(v);
      else if (v is Iterable)
        return out
          ..[k] = v
              .map((x) => x is! Map<String, dynamic> ? x : _serialize(x))
              .toList();
      else
        return out..[k] = v;
    });
  }

  @override
  RepositoryQuery<Map<String, dynamic>> all() {
    return new MongoRepositoryQuery(
        new MongoQueryBuilder(_mutex, _collection, null));
  }

  @override
  Future<InsertionResult> insert(Map<String, dynamic> data) async {
    if (data is Map<String, dynamic>) {
      try {
        var result = await _collection.insert(data);
        var created = await _collection
            .find(mgo.where.sortBy(r'$natural', descending: true))
            .first;
        var id = created['_id'] as mgo.ObjectId;
        return new InsertionResult(result['nInserted'], true,
            createdIds: [id.toHexString()],
            createdItems: [_serialize(created)]);
      } catch (e) {}
    } else
      throw new ArgumentError(
          'MongoRepositories only support insertion of Maps.');
  }

  @override
  Future<InsertionResult> insertAll(Iterable<Map<String, dynamic>> data) async {}

  @override
  RepositoryQuery<Map<String, dynamic>> raw(query) {
    if (query is mgo.SelectorBuilder)
      return new MongoRepositoryQuery(
          new MongoQueryBuilder(_mutex, _collection, query));
    else
      throw new ArgumentError(
          'Raw queries on Mongo databases must be SelectorBuilders. You supplied: $query');
  }
  @override
  Future close() async {
    try {
      _changes.close();
    } catch(e) {
      // Fail silently
    }
  }
}
