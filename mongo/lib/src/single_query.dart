import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:query_builder/query_builder.dart';
import 'builder.dart';

class MongoSingleQuery extends SingleQuery<Map<String, dynamic>> {
  final bool _serializeId;
  final MongoSingleQueryBuilder builder;

  MongoSingleQuery(this.builder, this._serializeId);

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
  Future<DeletionResult<Map<String, dynamic>>> delete() {
    // TODO: implement delete
  }

  @override
  Future<Map<String, dynamic>> get() => builder.get().then(_serialize);

  @override
  SingleQuery<Map<String, dynamic>> increment(String fieldName,
      [int amount = 1, Map<String, dynamic> additionalFields = const {}]) {
    // TODO: implement increment
  }

  @override
  Future<UpdateResult<Map<String, dynamic>>> update(
      Map<String, dynamic> fields) async {
    try {
      await builder.collection.update(builder.query.limit(1), fields);
      var current = await get();
      return new UpdateResult(1, true,
          updatedIds: [current['_id']], updatedItems: [current]);
    } on mgo.MongoDartError catch (e, st) {
      return new UpdateResult(0, false, message: e.message, stackTrace: st);
    } catch (e, st) {
      return new UpdateResult(0, false, message: e.toString(), stackTrace: st);
    }
  }

  @override
  Future<UpdateResult<Map<String, dynamic>>> updateJson(
          String fieldName, value) =>
      update({fieldName: value});
}
