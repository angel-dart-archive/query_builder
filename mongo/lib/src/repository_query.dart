import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mgo;
import 'package:query_builder/query_builder.dart';
import 'builder.dart';

class MongoRepositoryQuery extends RepositoryQuery<Map<String, dynamic>> {
  final MongoQueryBuilder builder;

  MongoRepositoryQuery(this.builder);
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
    // TODO: implement orderBy
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
    // TODO: implement skip
  }

  @override
  Future<num> sum(String fieldName) {
    // TODO: implement sum
  }

  @override
  RepositoryQuery<Map<String, dynamic>> take(int count) {
    // TODO: implement take
  }

  @override
  RepositoryQuery<Map<String, dynamic>> union(
      RepositoryQuery<Map<String, dynamic>> other) {
    // TODO: implement union
  }

  @override
  RepositoryQuery<Map<String, dynamic>> unionAll(
      RepositoryQuery<Map<String, dynamic>> other) {
    // TODO: implement unionAll
  }

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
    // TODO: implement whereDay
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereEquality(
      String fieldName, value, Equality equality) {
    // TODO: implement whereEquality
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereHasField(String fieldName) {
    // TODO: implement whereHasField
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
    // TODO: implement whereNotNull
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereNull(String fieldName) {
    // TODO: implement whereNull
  }

  @override
  RepositoryQuery<Map<String, dynamic>> whereYear(String fieldName, int year) {
    // TODO: implement whereYear
  }
}
