import 'dart:async';
import 'package:data_store/data_store.dart';

class MapRepositoryQuery extends RepositoryQuery<Map<String, dynamic>> {
  final Stream<ChangeEvent<Map<String, dynamic>>> _changes;
  final Map<String, Map<String, dynamic>> _items;

  MapRepositoryQuery(this._items, this._changes);

  @override
  Future<num> average(String fieldName) {
    // TODO: implement average
  }

  @override
  Stream<ChangeEvent<Map<String, dynamic>>> changes() => _changes;

  @override
  Future<int> count() async => _items.length;

  @override
  Future<DeletionResult<Map<String, dynamic>>> delete() {
    // TODO: implement delete
  }

  @override
  RepositoryQuery<Map<String, dynamic>> distinct() => this;

  @override
  SingleQuery<Map<String, dynamic>> first() {
    // TODO: implement first
  }

  @override
  Stream<Map<String, dynamic>> get() async* {
    for (var item in _items) yield item;
  }

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
  RepositoryQuery<Map<String, dynamic>> orderBy(
      String fieldName, OrderBy orderBy) {
    // TODO: implement orderBy
  }

  @override
  Future<List> pluck<U>(String fieldName) {
    // TODO: implement pluck
  }

  @override
  RepositoryQuery<Map<String, dynamic>> select(List selectors) {
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
  Future<List<UpdateResult<Map<String, dynamic>>>> updateAll(
      Map<String, dynamic> fields) {
    // TODO: implement updateAll
  }

  @override
  WhereQuery<Map<String, dynamic>> where(String fieldName, value) {
    // TODO: implement where
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
    // TODO: implement whereEquality
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
