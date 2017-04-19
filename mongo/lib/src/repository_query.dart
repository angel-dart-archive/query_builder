import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:query_builder/query_builder.dart';
import 'builder.dart';

class MongoRepositoryQuery extends RepositoryQuery<Map<String, dynamic>> {
  final MongoQueryBuilder builder;

  MongoRepositoryQuery(this.builder);

  MongoRepositoryQuery _changeBuilder(
      mgo.SelectorBuilder apply(mgo.SelectorBuilder builder)) {
    return new MongoRepositoryQuery(new MongoQueryBuilder(builder.mutex,
        builder.collection, apply(builder.query ?? mgo.where.exists('_id'))));
  }

  @override
  Future<num> average(String fieldName) {
    // TODO: implement average
  }

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() {
    // TODO: implement changes
  }

  @override
  Future<int> count() => builder.collection.find(builder.query).length;

  @override
  Future<DeletionResult<Map<String, dynamic>>> delete() async {
    try {
      var result = await builder.collection.remove(builder.query);
      return new DeletionResult(result['nRemoved'], true);
    } catch (e) {
      return new DeletionResult(0, false);
    }
  }

  @override
  RepositoryQuery<Map<String, dynamic>> distinct() {
    // TODO: implement distinct
  }

  @override
  SingleQuery<Map<String, dynamic>> first() {
    // TODO: implement first
  }

  @override
  Stream<Map<String, dynamic>> get() => builder.collection.find(builder.query);

  @override
  RepositoryQuery<Map<String, dynamic>> groupBy(String fieldName) {
    // TODO: implement groupBy
  }

  @override
  RepositoryQuery<Map<String, dynamic>> inRandomOrder() {
    // TODO: implement inRandomOrder
  }

  @override
  Future<num> max(String fieldName) {
    // TODO: implement max
  }

  @override
  RepositoryQuery<Map<String, dynamic>> mutex() {
    // TODO: implement mutex
  }

  @override
  RepositoryQuery<Map<String, dynamic>> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]) {
    return _changeBuilder(
        (q) => q.sortBy(fieldName, descending: orderBy == OrderBy.DESCENDING));
  }

  @override
  Future<Iterable> pluck<U>(Iterable<String> fieldNames) {
    // TODO: implement pluck
  }

  @override
  RepositoryQuery<Map<String, dynamic>> select(Iterable selectors) {
    // TODO: implement select
  }

  @override
  RepositoryQuery<Map<String, dynamic>> skip(int count) {
    return _changeBuilder((q) => q.skip(count));
  }

  @override
  Future<num> sum(String fieldName) {
    // TODO: implement sum
  }

  @override
  RepositoryQuery<Map<String, dynamic>> take(int count) {
    return _changeBuilder((q) => q.limit(count));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> union(
      RepositoryQuery<Map<String, dynamic>> other) {
    if (other is MongoRepositoryQuery)
      return _changeBuilder(
          (q) => q.and(other.builder.query ?? mgo.where.exists('_id')));
    else
      throw new ArgumentError(
          'MongoRepositoryQueries can only be unioned with other MongoRepositoryQueries.');
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
    return _changeBuilder((q) =>
        q.gte(fieldName, date).lt(fieldName, date.add(new Duration(days: 1))));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereDay(String fieldName, int day) {
    // TODO: implement whereDay
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereEquality(
      String fieldName, value, Equality equality) {
    if (equality == Equality.EQUAL)
      return _changeBuilder((q) => q.and(mgo.where.eq(fieldName, value)));
    else if (equality == Equality.GREATER_THAN)
      return _changeBuilder((q) => q.gt(fieldName, value));
    else if (equality == Equality.GREATER_THAN_OR_EQUAL_TO)
      return _changeBuilder((q) => q.gte(fieldName, value));
    else if (equality == Equality.LESS_THAN)
      return _changeBuilder((q) => q.lt(fieldName, value));
    else if (equality == Equality.LESS_THAN_OR_EQUAL_TO)
      return _changeBuilder((q) => q.lte(fieldName, value));
    else if (equality == Equality.LESS_THAN_OR_GREATER_THAN)
      return _changeBuilder(
          (q) => q.lt(fieldName, value).or(mgo.where.gt(fieldName, value)));
    else
      return _changeBuilder((q) => q.ne(fieldName, value));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereHasField(String fieldName) {
    return _changeBuilder((q) => q.exists(fieldName));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereIn(
      String fieldName, Iterable values) {
    // TODO: implement whereIn
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
    // TODO: implement whereMonth
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotBetween(
      String fieldName, Iterable values) {
    // TODO: implement whereNotBetween
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotIn(
      String fieldName, Iterable values) {
    // TODO: implement whereNotIn
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNotNull(String fieldName) {
    return _changeBuilder((q) => q.and(mgo.where.ne(fieldName, null)));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNull(String fieldName) {
    return _changeBuilder((q) => q.and(mgo.where.eq(fieldName, null)));
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereYear(String fieldName, int year) {
    // TODO: implement whereYear
  }
}
