import 'dart:async';
import 'package:query_builder/query_builder.dart';

class InMemoryQueryBuilder {
  final StreamController<ChangeEvent<Map<String, dynamic>>> changes;
  final Iterable<Map<String, dynamic>> _items;

  Iterable<Map<String, dynamic>> get items => _items;

  final List<String> pluck = [];

  final Map<String, dynamic> where = {};

  InMemoryQueryBuilder(this._items, this.changes);

  Future<List<Map<String, dynamic>>> apply() async {
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

    return result.toList();
  }

  void cloneFrom(InMemoryQueryBuilder other) {}

  InMemoryQueryBuilder changeItems(Iterable<Map<String, dynamic>> items) {
    return new InMemoryQueryBuilder(items, changes)..cloneFrom(this);
  }
}
