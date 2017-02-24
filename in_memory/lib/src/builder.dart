import 'dart:async';
import 'package:mutex/mutex.dart';
import 'package:query_builder/query_builder.dart';

class InMemoryQueryBuilder {
  final StreamController<ChangeEvent<Map<String, dynamic>>> changes;
  final Map<String, Map<String, dynamic>> _original;
  final Iterable<Map<String, dynamic>> _items;
  final ReadWriteMutex _mutex;

  Iterable<Map<String, dynamic>> get items => _items;

  final List<String> pluck = [];

  final Map<String, dynamic> where = {};

  bool useMutex = false;

  InMemoryQueryBuilder(this._mutex, this._original, this._items, this.changes);

  Future<List<Map<String, dynamic>>> apply() async {
    if (useMutex == true) _mutex.acquireRead();

    Iterable<Map<String, dynamic>> result = []..addAll(_items);

    if (pluck.isNotEmpty) {
      for (var key in pluck) {
        result = result.map((map) {
          if (map.containsKey(key))
            return map[key];
          else
            return null;
        });
      }
    }

    if (useMutex == true) _mutex.release();

    return result.toList();
  }

  void cloneFrom(InMemoryQueryBuilder other) {}

  InMemoryQueryBuilder changeItems(Iterable<Map<String, dynamic>> items) {
    return new InMemoryQueryBuilder(_mutex, _original, items, changes)
      ..cloneFrom(this);
  }
}
