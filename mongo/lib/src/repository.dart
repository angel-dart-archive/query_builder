import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:query_builder/query_builder.dart';
import 'builder.dart';
import 'repository_query.dart';
import 'single_query.dart';

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

  MongoRepository(this._collection, this._serializeId);

  Map<String, dynamic> _serialize(Map<String, dynamic> map) {
    if (!_serializeId) return map;

    return map.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var v = map[k];

      if (v is mgo.ObjectId && _serializeId)
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
        new MongoQueryBuilder(_collection, null), _serializeId != false);
  }

  @override
  SingleQuery<Map> find(String id) => new MongoSingleQuery(
      new MongoSingleQueryBuilder(
          _collection,
          mgo.where
              .id(id is mgo.ObjectId ? id : mgo.ObjectId.parse(id.toString()))),
      _serializeId != false);

  @override
  Future<InsertionResult> insert(Map<String, dynamic> data) async {
    try {
      await _collection.insert(data);
      var created = await _collection
          .find(mgo.where.sortBy(r'$natural', descending: true))
          .first;
      var id = created['_id'] as mgo.ObjectId;
      return new InsertionResult(1, true,
          createdIds: [id.toHexString()], createdItems: [_serialize(created)]);
    } on mgo.MongoDartError catch (e, st) {
      return new InsertionResult(0, false, message: e.message, stackTrace: st);
    } catch (e, st) {
      return new InsertionResult(0, false,
          message: e.toString(), stackTrace: st);
    }
  }

  @override
  Future<InsertionResult> insertAll(Iterable<Map<String, dynamic>> data) async {
    List<String> createdIds = [];
    List<Map<String, dynamic>> createdItems = [];

    try {
      await _collection.insertAll(data);
      var stream = _collection
          .find(mgo.where.sortBy(r'$natural', descending: true))
          .take(data.length);

      await for (var created in stream) {
        var id = created['_id'] as mgo.ObjectId;
        createdIds.insert(0, id.toHexString());
        createdItems.insert(0, _serialize(created));
      }

      return new InsertionResult(data.length, true,
          createdIds: createdIds, createdItems: createdItems);
    } on mgo.MongoDartError catch (e, st) {
      return new InsertionResult(0, false, message: e.message, stackTrace: st);
    } catch (e, st) {
      return new InsertionResult(0, false,
          message: e.toString(), stackTrace: st);
    }
  }

  @override
  RepositoryQuery<Map<String, dynamic>> raw(query) {
    if (query is mgo.SelectorBuilder)
      return new MongoRepositoryQuery(
          new MongoQueryBuilder(_collection, query), _serializeId != false);
    else
      throw new ArgumentError(
          'Raw queries on Mongo databases must be SelectorBuilders. You supplied: $query');
  }

  @override
  Future close() async {
    try {
      _changes.close();
    } catch (e) {
      // Fail silently
    }
  }
}
