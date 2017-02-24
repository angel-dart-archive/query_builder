import 'dart:async';
import 'dart:math' as math;
import 'package:query_builder/query_builder.dart';
import 'builder.dart';

final math.Random _rnd = new math.Random();

class MapRepositoryQuery extends RepositoryQuery<Map<String, dynamic>> {
  final InMemoryQueryBuilder _builder;

  MapRepositoryQuery(this._builder);

  @override
  Future<num> average(String fieldName) {
    return sum(fieldName).then((sum) {
      return sum.toDouble() / _builder.items.length;
    });
  }

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() =>
      _builder.changes.stream;

  @override
  Future<int> count() => _builder.apply().then((l) => l.length);

  @override
  Future<DeletionResult<Map<String, dynamic>>> delete() {
    // TODO: implement delete
  }

  @override
  RepositoryQuery<Map<String, dynamic>> distinct() {
    List<Map<String, dynamic>> result = [];

    for (var item in _builder.items) {
      if (!result.contains(item)) result.add(item);
    }

    return new MapRepositoryQuery(_builder.changeItems(result));
  }

  @override
  SingleQuery<Map<String, dynamic>> first() {
    // TODO: implement first
  }

  @override
  Stream<Map<String, dynamic>> get() async* {
    for (var item in await _builder.apply()) yield item;
  }

  @override
  RepositoryQuery<Map<String, dynamic>> groupBy(String fieldName) =>
      orderBy(fieldName);

  @override
  RepositoryQuery<Map<String, dynamic>> inRandomOrder() {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.toList()..shuffle(_rnd)));
  }

  @override
  Future<num> max(String fieldName) async {
    var result = 0;

    for (var item in await _builder.apply()) {
      if (item[fieldName] is num && item[fieldName] > result)
        result = item[fieldName];
    }

    return result;
  }

  @override
  RepositoryQuery<Map<String, dynamic>> mutex() {
    return this.._builder.useMutex = true;
  }

  @override
  RepositoryQuery<Map<String, dynamic>> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]) {
    var sorted = _builder.items.toList()
      ..sort((a, b) {
        if (a.containsKey(fieldName)) {
          if (!b.containsKey(fieldName))
            return 1;
          else {
            var first = a[fieldName], second = b[fieldName];

            if (first is num && second is num)
              return first.compareTo(second);
            else if (first is DateTime && second is DateTime)
              return first.compareTo(second);
            else if (first is Iterable && second is Iterable)
              return first.length.compareTo(second.length);
            else
              return first.toString().compareTo(second.toString());
          }
        } else {
          if (b.containsKey(fieldName))
            return -1;
          else
            return 0;
        }
      });

    if (orderBy == OrderBy.DESCENDING) sorted = sorted.reversed;

    return new MapRepositoryQuery(_builder.changeItems(sorted));
  }

  @override
  Future<Iterable<U>> pluck<U>(Iterable<String> fieldNames) async {
    var items = await _builder.apply();
    return items.map((m) {
      return m.keys
          .where((k) => fieldNames.contains(k))
          .map<U>((k) => m[k] as U)
          .toList();
    }).fold<List<U>>([], (a, b) => a..addAll(b));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> select(Iterable selectors) {
    return new MapRepositoryQuery(_builder.changeItems(_builder.items.map((m) {
      Map<String, dynamic> result = {};

      for (var selector in selectors) {
        if (selector is String)
          result[selector] = m[selector];
        else if (selector is Map<String, dynamic>) {
          for (var key in selector.keys) {
            result[selector[key]] = m[key];
          }
        } else
          throw new ArgumentError(
              'Invalid selector: $selector. Only String and Map<String, dynamic> are supported.');
      }

      return result;
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> skip(int count) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.skip(count)));
  }

  @override
  Future<num> sum(String fieldName) async {
    var result = 0;

    for (var item in await _builder.apply()) {
      if (item[fieldName] is num) result += item[fieldName];
    }

    return result;
  }

  @override
  RepositoryQuery<Map<String, dynamic>> take(int count) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.take(count)));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> union(
      RepositoryQuery<Map<String, dynamic>> other) {
    assert(other is MapRepositoryQuery,
        'In-memory queries can only be chained to other in-memory queries.');

    var o = other as MapRepositoryQuery;
    return new MapRepositoryQuery(_builder
        .changeItems([]..addAll(_builder.items)..addAll(o._builder.items)));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> unionAll(
          RepositoryQuery<Map<String, dynamic>> other) =>
      union(other);

  @override
  Future<Iterable<UpdateResult<Map<String, dynamic>>>> updateAll(
      Map<String, dynamic> fields) {
    // TODO: implement updateAll
  }
  @override
  RepositoryQuery<Map<String, dynamic>> whereBetween(
      String fieldName, Iterable values) {
    // TODO: implement whereBetween
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereColumn(
      String first, String second) {
    // TODO: implement whereColumn
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereDate(
      String fieldName, DateTime date) {
    // TODO: implement whereDate
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereDay(String fieldName, int day) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m[fieldName] is DateTime && m[fieldName].day == day;
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereEquality(
      String fieldName, value, Equality equality) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      if (!m.containsKey(fieldName))
        return false;
      else {
        var val = m[fieldName];

        if (equality == Equality.EQUAL)
          return val == value;
        else if (equality == Equality.NOT_EQUAL)
          return val != value;
        else if (equality == Equality.GREATER_THAN)
          return val > value;
        else if (equality == Equality.GREATER_THAN_OR_EQUAL_TO)
          return val >= value;
        else if (equality == Equality.LESS_THAN)
          return val < value;
        else if (equality == Equality.LESS_THAN_OR_EQUAL_TO)
          return val <= value;
        else
          return false;
      }
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereHasField(String fieldName) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m.containsKey(fieldName);
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereIn(
      String fieldName, Iterable values) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m.containsKey(fieldName) && values.contains(m[fieldName]);
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereJson(String fieldName, value) {
    // TODO: implement whereJson
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereLike(String fieldName, value) {
    // TODO: implement whereLike
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereMonth(
      String fieldName, int month) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m[fieldName] is DateTime && m[fieldName].month == month;
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotBetween(
      String fieldName, Iterable values) {
    // TODO: implement whereNotBetween
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotIn(
      String fieldName, Iterable values) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m.containsKey(fieldName) && !values.contains(m[fieldName]);
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotNull(String fieldName) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m.containsKey(fieldName) && m[fieldName] == null;
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNull(String fieldName) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m.containsKey(fieldName) && m[fieldName] == null;
    })));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereYear(String fieldName, int year) {
    return new MapRepositoryQuery(
        _builder.changeItems(_builder.items.where((m) {
      return m[fieldName] is DateTime && m[fieldName].year == year;
    })));
  }
}
