import 'dart:async';
import 'package:data_store/data_store.dart';
import 'repository_query.dart';

// TODO: Add change event support
class MapRepository extends Repository<Map<String, dynamic>> {
  final StreamController<ChangeEvent<Map<String, dynamic>>> _changes =
      new StreamController<ChangeEvent<Map<String, dynamic>>>.broadcast();
  final Map<String, Map<String, dynamic>> _items = {};

  @override
  RepositoryQuery<Map<String, dynamic>> all() =>
      new MapRepositoryQuery(_items, _changes.stream);

  @override
  Future<InsertionResult> insert(data) async {
    assert(data is Map, 'MapRepository only supports Maps.');
    String id = _items.length.toString();
    Map item = {}
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
      String id = _items.length.toString();
      Map item = {}
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
