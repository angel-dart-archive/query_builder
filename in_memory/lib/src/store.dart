import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'repository.dart';

class InMemoryDataStore extends DataStore<Map<String, dynamic>> {
  bool _closed = false;

  final Map<String, InMemoryRepository> _repos = {};

  @override
  Repository<Map<String, dynamic>> repository(String tableName) {
    if (_closed)
      throw new StateError('Cannot access a closed InMemoryDataStore.');
    return _repos.putIfAbsent(tableName, () => new InMemoryRepository());
  }

  @override
  Future close() async {
    _closed = true;
    for (var repo in _repos.values) await repo.close();
  }
}
