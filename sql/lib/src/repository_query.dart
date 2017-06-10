import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'join_type.dart';
import 'verb.dart';
import 'query.dart';

abstract class SqlRepositoryQuery<T> extends RepositoryQuery<T> {
  final String tableName, verb;
  final List<String> selectFields = [];
  final Map<String, dynamic> whereFields = {};
  final List<String> orConditions = [];
  final Map<String, SQLJoinType> joins = {};
  int limit, offset;

  SqlRepositoryQuery(this.tableName, this.verb);

  static String escapeFieldName(String fieldName) {
    // TODO: Finish escapeFieldName
  }

  /// Transforms a value into a sanitized String suitable for SQL.
  static String stringify(value) {
    if (value is num) return value.toString();
    // TODO: Finish stringify
  }

  String toSql() {
    // TODO: Finish toSQL
  }

  @override
  Future<num> average(String fieldName) {
    // TODO: implement average
  }

  @override
  Future<int> count() {
    // TODO: implement count
  }

  @override
  Future<DeletionResult<T>> delete() {
    // TODO: implement delete
  }

  @override
  RepositoryQuery<T> distinct(String fieldName) {
    // TODO: implement distinct
  }

  @override
  SingleQuery<T> first() {
    // TODO: implement first
  }

  @override
  RepositoryQuery<T> groupBy(String fieldName) {
    // TODO: implement groupBy
  }

  @override
  RepositoryQuery<T> inRandomOrder() {
    // TODO: implement inRandomOrder
  }

  @override
  Future<num> max(String fieldName) {
    // TODO: implement max
  }

  @override
  Future<num> min(String fieldName) {
    // TODO: implement min
  }

  @override
  RepositoryQuery<T> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]) {
    // TODO: implement orderBy
  }

  @override
  Future<Iterable> pluck<U>(Iterable<String> fieldNames) {
    // TODO: implement pluck
  }

  @override
  RepositoryQuery<T> select(Iterable selectors) {
    // TODO: implement select
  }

  @override
  RepositoryQuery<T> skip(int count) {
    return this..offset = count;
  }

  @override
  Future<num> sum(String fieldName) {
    // TODO: implement sum
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
  RepositoryQuery<T> whereBetween(String fieldName, Iterable values) {
    // TODO: implement whereBetween
  }

  @override
  RepositoryQuery<T> whereDate(String fieldName, DateTime date) {
    // TODO: implement whereDate
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
  RepositoryQuery<T> whereNotBetween(String fieldName, Iterable values) {
    // TODO: implement whereNotBetween
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
