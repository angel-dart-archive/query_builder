import 'package:query_builder/query_builder.dart';
import 'repository.dart';

class InMemoryDataStore extends DataStore<Map<String, dynamic>> {
  final Map<String, MapRepository> _repos = {};

  @override
  Repository<Map<String, dynamic>> repository(String tableName) {
    return _repos.containsKey(tableName)
        ? _repos[tableName]
        : _repos[tableName] = new MapRepository();
  }
}
