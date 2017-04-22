import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder/query_builder.dart';
import 'package:query_builder/src/data_store.dart';
import 'repository.dart';

class MongoDataStore extends DataStore<Map<String, dynamic>> {
  bool _closed = false;
  Map<String, MongoRepository> _repositories = {};

  final Db db;

  /// If `true` (default), then ObjectIds will automatically be serialized into hex strings.
  final bool serializeIds;

  MongoDataStore(this.db, {this.serializeIds: true});

  @override
  MongoRepository repository(String tableName) {
    if (_closed)
      throw new StateError('Cannot access a closed InMemoryDataStore.');
    return _repositories.putIfAbsent(
        tableName,
        () => new MongoRepository(
            db.collection(tableName), this.serializeIds != false));
  }

  @override
  Future close() async {
    _closed = true;

    for (var repo in _repositories.values) {
      await repo.close();
    }

    await db.close();
  }
}
