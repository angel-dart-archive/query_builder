import 'package:mongo_dart/mongo_dart.dart';
import 'package:query_builder/query_builder.dart';
import 'package:query_builder/src/data_store.dart';
import 'repository.dart';

class MongoDataStore extends DataStore<Map<String, dynamic>> {
  final Db db;

  /// If `true` (default), then ObjectIds will automatically be serialized into hex strings.
  final bool serializeIds;

  MongoDataStore(this.db, {this.serializeIds: true});

  @override
  MongoRepository repository(String tableName) {
    return new MongoRepository(
        db.collection(tableName), this.serializeIds != false);
  }
}
