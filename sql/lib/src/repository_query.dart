import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'join_type.dart';
import 'verb.dart';
import 'query.dart';

abstract class SqlRepositoryQuery<T> extends RepositoryQuery<T> {
  final String tableName, verb;
  final Map<String, String> selectFields = {};
  final Map<String, String> whereFields = {};
  final List<String> orConditions = [], distinctFields = [];
  final Map<String, SQLJoinType> joins = {};
  final Map<String, OrderBy> sort = {};
  String groupByField;
  int limit, offset;

  SqlRepositoryQuery(this.tableName, this.verb);

  static String escapeFieldName(String fieldName) {
    // TODO: Finish escapeFieldName
  }

  Future<int> executeAsInt(String query);

  Future<num> executeAsNum(String query);

  /// Transforms a value into a sanitized String suitable for SQL.
  String stringify(value) {
    if (value is num)
      return value.toString();
    else if (value is DateTime) return dateToSql(value, true);
    // TODO: Finish stringify
  }

  String dateToSql(DateTime dt, bool time);

  String toSql({bool semicolon: true}) {
    // TODO: Finish toSQL
  }

  String toWhereCondition() {
    var str = '';

    if (whereFields.isEmpty) {
      return compileOrConditions();
    } else {
      int i = 0;

      whereFields.forEach((k, v) {
        if (i++ > 0) str += ' AND ';
        str += '($v)';
      });

      var or = compileOrConditions();
      if (or != null) str += ' OR ($or)';
    }

    return str;
  }

  String compileOrConditions() {
    if (orConditions.isEmpty) return null;
    var str = '';

    for (int i = 0; i < orConditions.length; i++) {
      var cond = '(${orConditions[i]})';
      if (i > 0) str += ' OR ';
      str += cond;
    }

    return str;
  }

  @override
  Future<num> average(String fieldName) {
    var escaped = escapeFieldName(fieldName);
    var query = toSql(semicolon: false);
    return executeAsNum('SELECT AVG(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  Future<int> count() {
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT COUNT(*) FROM ($query) AS `value`;');
  }

  @override
  Future<DeletionResult<T>> delete() {
    // TODO: implement delete
  }

  @override
  RepositoryQuery<T> distinct(String fieldName) {
    return this..distinctFields.add(escapeFieldName(fieldName));
  }

  @override
  SingleQuery<T> first() {
    // TODO: implement first
  }

  @override
  RepositoryQuery<T> groupBy(String fieldName) {
    return this..groupByField = escapeFieldName(fieldName);
  }

  @override
  RepositoryQuery<T> inRandomOrder() {
    return this..sort['*'] = OrderBy.RANDOM;
  }

  @override
  Future<num> max(String fieldName) {
    var escaped = escapeFieldName(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT MAX(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  Future<num> min(String fieldName) {
    var escaped = escapeFieldName(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT MIN(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  RepositoryQuery<T> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]) {
    return this
      ..sort[escapeFieldName(fieldName)] = orderBy ?? OrderBy.ASCENDING;
  }

  @override
  Future<Iterable> pluck<U>(Iterable<String> fieldNames) {
    // TODO: implement pluck
  }

  @override
  RepositoryQuery<T> select(Iterable selectors) {
    for (var selector in selectors) {
      if (selector is String) {
        var escaped = escapeFieldName(selector);
        selectFields[escaped] = escaped;
      } else if (selector is Map) {
        selector.forEach((k, v) {
          var escaped = escapeFieldName(k.toString());
          selectFields[escaped] = escapeFieldName(v.toString());
        });
      } else
        throw new ArgumentError('Cannot select $selector in a SQL query.');
    }

    return this;
  }

  @override
  RepositoryQuery<T> skip(int count) {
    return this..offset = count;
  }

  @override
  Future<num> sum(String fieldName) {
    var escaped = escapeFieldName(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT SUM(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  RepositoryQuery<T> take(int count) {
    return this..limit = count;
  }

  @override
  RepositoryQuery<T> union(RepositoryQuery<T> other) {
    // TODO: implement union
  }

  @override
  RepositoryQuery<T> unionAll(RepositoryQuery<T> other) {
    // TODO: implement unionAll
  }

  @override
  Future<Iterable<UpdateResult<T>>> updateAll(Map<String, dynamic> fields) {
    // TODO: implement updateAll
  }

  @override
  RepositoryQuery<T> whereBetween(String fieldName, lower, upper) {
    var f = stringify(lower), s = stringify(upper);
    return this..whereFields[escapeFieldName(fieldName)] = 'BETWEEN $f AND $s';
  }

  @override
  RepositoryQuery<T> whereDate(String fieldName, DateTime date,
      {bool time: true}) {
    return this
      ..whereFields[escapeFieldName(fieldName)] =
          '= ' + dateToSql(date, time != false);
  }

  @override
  RepositoryQuery<T> whereDay(String fieldName, int day) {
    return this..whereFields['DAY(`${escapeFieldName(fieldName)}`)'] = '= $day';
  }

  @override
  RepositoryQuery<T> whereEquality(String fieldName, value, Equality equality) {
    String condition, escaped = escapeFieldName(fieldName);

    switch (equality) {
      case Equality.EQUAL:
        condition = '= ' + stringify(value);
        break;
      case Equality.NOT_EQUAL:
        condition = 'NOT ' + stringify(value);
        break;
      case Equality.LESS_THAN:
        condition = '< ' + stringify(value);
        break;
      case Equality.LESS_THAN_OR_EQUAL_TO:
        condition = '<= ' + stringify(value);
        break;
      case Equality.GREATER_THAN:
        condition = '> ' + stringify(value);
        break;
      case Equality.GREATER_THAN_OR_EQUAL_TO:
        condition = '>= ' + stringify(value);
        break;
      case Equality.LESS_THAN_OR_GREATER_THAN:
        var str = stringify(value);
        whereFields[escaped] = '< ' + str;
        return this..orConditions.add('`$escaped` > $str');
    }

    return this..whereFields[escaped] = condition;
  }

  @override
  RepositoryQuery<T> whereIn(String fieldName, Iterable values) {
    int i = 0;
    var escaped = escapeFieldName(fieldName);

    for (var value in values) {
      if (i++ == 0) {
        whereFields[escaped] = '= ' + stringify(value);
      } else {
        orConditions.add('`$escaped` = ' + stringify(value));
      }
    }

    return this;
  }

  @override
  RepositoryQuery<T> whereLike(String fieldName, value) {
    return this
      ..whereFields['year(`${escapeFieldName(fieldName)}`)'] =
          'LIKE ' + stringify(value);
  }

  @override
  RepositoryQuery<T> whereMonth(String fieldName, int month) {
    return this
      ..whereFields['MONTH(`${escapeFieldName(fieldName)}`)'] = '= $month';
  }

  @override
  RepositoryQuery<T> whereNotBetween(String fieldName, lower, upper) {
    var f = stringify(lower), s = stringify(upper);
    return this
      ..whereFields[escapeFieldName(fieldName)] = 'NOT BETWEEN $f AND $s';
  }

  @override
  RepositoryQuery<T> whereNotIn(String fieldName, Iterable values) {
    int i = 0;
    var escaped = escapeFieldName(fieldName);

    for (var value in values) {
      if (i++ == 0) {
        whereFields[escaped] = '!= ' + stringify(value);
      } else {
        orConditions.add('`$escaped` != ' + stringify(value));
      }
    }

    return this;
  }

  @override
  RepositoryQuery<T> whereYear(String fieldName, int year) {
    return this
      ..whereFields['YEAR(`${escapeFieldName(fieldName)}`)'] = '= $year';
  }
}
