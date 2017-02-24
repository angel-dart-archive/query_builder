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
  RepositoryQuery<Map<String, dynamic>> groupBy(String fieldName) {
    // TODO: implement groupBy
  }

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
  WhereQuery<Map<String, dynamic>> whereBetween(
      String fieldName, Iterable values) {
    // TODO: implement whereBetween
  }

  @override
  WhereQuery<Map<String, dynamic>> whereColumn(String first, String second) {
    // TODO: implement whereColumn
  }

  @override
  WhereQuery<Map<String, dynamic>> whereDate(String fieldName, DateTime date) {
    // TODO: implement whereDate
  }

  @override
  WhereQuery<Map<String, dynamic>> whereDay(String fieldName, int day) {
    // TODO: implement whereDay
  }

  @override
  WhereQuery<Map<String, dynamic>> whereEquality(
      String fieldName, value, Equality equality) {
    return new MapWhereQuery(_builder, _builder.items.where((m) {
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
    }));
  }

  @override
  WhereQuery<Map<String, dynamic>> whereExists(
      builder(RepositoryQuery<Map<String, dynamic>> query)) {
    // TODO: implement whereExists
  }

  @override
  WhereQuery<Map<String, dynamic>> whereIn(String fieldName, Iterable values) {
    // TODO: implement whereIn
  }

  @override
  WhereQuery<Map<String, dynamic>> whereJson(String fieldName, value) {
    // TODO: implement whereJson
  }

  @override
  WhereQuery<Map<String, dynamic>> whereLike(String fieldName, value) {
    // TODO: implement whereLike
  }

  @override
  WhereQuery<Map<String, dynamic>> whereMonth(String fieldName, int month) {
    // TODO: implement whereMonth
  }

  @override
  WhereQuery<Map<String, dynamic>> whereNotBetween(
      String fieldName, Iterable values) {
    // TODO: implement whereNotBetween
  }

  @override
  WhereQuery<Map<String, dynamic>> whereNotIn(
      String fieldName, Iterable values) {
    // TODO: implement whereNotIn
  }

  @override
  WhereQuery<Map<String, dynamic>> whereNotNull(String fieldName) {
    // TODO: implement whereNotNull
  }

  @override
  WhereQuery<Map<String, dynamic>> whereNull(String fieldName) {
    // TODO: implement whereNull
  }

  @override
  WhereQuery<Map<String, dynamic>> whereYear(String fieldName, int year) {
    // TODO: implement whereYear
  }
}

class MapWhereQuery extends WhereQuery<Map<String, dynamic>> {
  final InMemoryQueryBuilder _builder;
  MapRepositoryQuery _inner;

  MapWhereQuery(this._builder, Iterable<Map<String, dynamic>> items) {
    _inner = new MapRepositoryQuery(_builder.changeItems(items));
  }
  @override
  Future<num> average(String fieldName) => _inner.average(fieldName);

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() => _inner.changes();

  @override
  Future<int> count() => _inner.count();

  @override
  Future<DeletionResult<Map<String, dynamic>>> delete() => _inner.delete();

  @override
  RepositoryQuery<Map<String, dynamic>> distinct() => _inner.distinct();

  @override
  SingleQuery<Map<String, dynamic>> first() => _inner.first();

  @override
  Stream<Map<String, dynamic>> get() => _inner.get();

  @override
  RepositoryQuery<Map<String, dynamic>> groupBy(String fieldName) =>
      _inner.groupBy(fieldName);

  @override
  RepositoryQuery<Map<String, dynamic>> inRandomOrder() =>
      _inner.inRandomOrder();

  @override
  Future<num> max(String fieldName) => _inner.max(fieldName);

  @override
  RepositoryQuery<Map<String, dynamic>> mutex() => _inner.mutex();

  @override
  RepositoryQuery<Map<String, dynamic>> orderBy(String fieldName,
          [OrderBy orderBy = OrderBy.ASCENDING]) =>
      _inner.orderBy(fieldName, orderBy ?? OrderBy.ASCENDING);

  @override
  Future<Iterable>
      pluck<U>(Iterable<String> fieldNames) => _inner.pluck<U>(fieldNames);

  @override
  RepositoryQuery<Map<String, dynamic>> select(Iterable selectors) =>
      _inner.select(selectors);

  @override
  RepositoryQuery<Map<String, dynamic>> skip(int count) => _inner.skip(count);

  @override
  Future<num> sum(String fieldName) => _inner.sum(fieldName);
  @override
  RepositoryQuery<Map<String, dynamic>> take(int count) => _inner.take(count);

  @override
  RepositoryQuery<Map<String, dynamic>> union(
          RepositoryQuery<Map<String, dynamic>> other) =>
      _inner.union(other);

  @override
  RepositoryQuery<Map<String, dynamic>> unionAll(
          RepositoryQuery<Map<String, dynamic>> other) =>
      _inner.unionAll(other);

  @override
  Future<Iterable<UpdateResult<Map<String, dynamic>>>> updateAll(
          Map<String, dynamic> fields) =>
      _inner.updateAll(fields);

  @override
  WhereQuery<Map<String, dynamic>> whereBetween(
          String fieldName, Iterable values) =>
      _inner.whereBetween(fieldName, values);

  @override
  WhereQuery<Map<String, dynamic>> whereColumn(String first, String second) =>
      _inner.whereColumn(first, second);

  @override
  WhereQuery<Map<String, dynamic>> whereDate(String fieldName, DateTime date) =>
      _inner.whereDate(fieldName, date);

  @override
  WhereQuery<Map<String, dynamic>> whereDay(String fieldName, int day) =>
      _inner.whereDay(fieldName, day);

  @override
  WhereQuery<Map<String, dynamic>> whereEquality(
          String fieldName, value, Equality equality) =>
      _inner.whereEquality(fieldName, value, equality);

  @override
  WhereQuery<Map<String, dynamic>> whereExists(
          builder(RepositoryQuery<Map<String, dynamic>> query)) =>
      _inner.whereExists(builder);
  @override
  WhereQuery<Map<String, dynamic>> whereIn(String fieldName, Iterable values) =>
      _inner.whereIn(fieldName, values);

  @override
  WhereQuery<Map<String, dynamic>> whereJson(String fieldName, value) =>
      _inner.whereJson(fieldName, value);

  @override
  WhereQuery<Map<String, dynamic>> whereLike(String fieldName, value) =>
      _inner.whereLike(fieldName, value);

  @override
  WhereQuery<Map<String, dynamic>> whereMonth(String fieldName, int month) =>
      _inner.whereMonth(fieldName, month);

  @override
  WhereQuery<Map<String, dynamic>> whereNotBetween(
          String fieldName, Iterable values) =>
      _inner.whereNotBetween(fieldName, values);

  @override
  WhereQuery<Map<String, dynamic>> whereNotIn(
          String fieldName, Iterable values) =>
      _inner.whereNotIn(fieldName, values);

  @override
  WhereQuery<Map<String, dynamic>> whereNotNull(String fieldName) =>
      _inner.whereNotNull(fieldName);

  @override
  WhereQuery<Map<String, dynamic>> whereNull(String fieldName) =>
      _inner.whereNull(fieldName);

  @override
  WhereQuery<Map<String, dynamic>> whereYear(String fieldName, int year) =>
      _inner.whereYear(fieldName, year);
}
