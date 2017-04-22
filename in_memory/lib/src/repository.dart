import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'builder.dart';
import 'repository_query.dart';

// TODO: Add change event support
class InMemoryRepository extends Repository<Map<String, dynamic>> {
  final StreamController<ChangeEvent<Map<String, dynamic>>> _changes =
      new StreamController<ChangeEvent<Map<String, dynamic>>>.broadcast(
          onListen: () {
    print(
        'NOTE: You called changes() on an InMemoryRepository, but in-memory Maps do not send change events. ' +
            'The returned stream will never output any events.');
  });
  final List<Map<String, dynamic>> _items = [];

  @override
  RepositoryQuery<Map<String, dynamic>> all() {
    return new MapRepositoryQuery(new InMemoryQueryBuilder(_items, _changes));
  }

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() {
    return _changes.stream;
  }

  @override
  Future<InsertionResult> insert(data) async {
    if (data is! Map<String, dynamic>)
      return new InsertionResult(0, false,
          message: 'MapRepository only supports Maps.');

    var id = _items.length.toString();
    Map<String, dynamic> item = {}
      ..addAll(data)
      ..['id'] = id;
    _items.add(item);

    return new InsertionResult(1, true, createdIds: [id], createdItems: [item]);
  }

  @override
  Future<InsertionResult> insertAll(Iterable data) async {
    if (!data.every((x) => x is Map))
      return new InsertionResult(0, false,
          message: 'MapRepository only supports Maps.');

    var createdIds = <String>[], createdItems = <Map<String, dynamic>>[];

    for (Map<String, dynamic> datum in data) {
      var id = _items.length.toString();
      Map<String, dynamic> item = {}
        ..addAll(datum)
        ..['id'] = id;
      _items.add(item);
      createdIds.add(id);
      createdItems.add(item);
    }

    return new InsertionResult(createdItems.length, true,
        createdIds: createdIds, createdItems: createdItems);
  }

  @override
  RepositoryQuery<Map<String, dynamic>> raw(query) {
    throw new UnimplementedError('MapRepository does not support raw queries.');
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
