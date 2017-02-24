import 'dart:async';
import 'package:mutex/mutex.dart';
import 'package:query_builder/query_builder.dart';
import 'builder.dart';
import 'repository_query.dart';

// TODO: Add change event support
class MapRepository extends Repository<Map<String, dynamic>> {
  final StreamController<ChangeEvent<Map<String, dynamic>>> _changes =
      new StreamController<ChangeEvent<Map<String, dynamic>>>.broadcast();
  final Map<String, Map<String, dynamic>> _items = {};
  final ReadWriteMutex _mutex = new ReadWriteMutex();

  @override
  RepositoryQuery<Map<String, dynamic>> all() {
    return new MapRepositoryQuery(
        new InMemoryQueryBuilder(_mutex, _items, _items.values, _changes));
  }

  @override
  Future<InsertionResult> insert(data) async {
    assert(data is Map, 'MapRepository only supports Maps.');
    var id = _items.length;
    Map<String, dynamic> item = {}
      ..addAll(data)
      ..['id'] = id;
    _items[id] = item;

    return new InsertionResult(1, true, createdIds: [id], createdItems: [item]);
  }

  @override
  Future<InsertionResult> insertAll(Iterable data) async {
    assert(data.every((x) => x is Map), 'MapRepository only supports Maps.');
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
