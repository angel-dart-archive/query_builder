import 'package:data_store/data_store.dart';
import 'repository.dart';

class InMemoryDataStore extends DataStore {
  final Map<String, MapRepository> _repos = {};

  @override
  Repository<Map<String, dynamic>> repository<T>(String tableName) {
    assert(T == dynamic || T == Map,
        'In-memory data stores only support storing data into maps.');
    return _repos.containsKey(tableName)
        ? _repos[tableName]
        : _repos[tableName] = new MapRepository();
  }
}
