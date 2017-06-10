import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'repository_query.dart';

/// TODO: Throw errors!!!
class AbstractRepositoryQuery extends SqlRepositoryQuery {
  AbstractRepositoryQuery(String tableName) : super(tableName);

  @override
  Future<DeletionResult> delete() => null;

  @override
  Future<int> executeAsInt(String query) => null;

  @override
  Future<num> executeAsNum(String query) => null;

  @override
  SingleQuery first() => null;

  @override
  Stream get() => null;

  @override
  Future<Iterable> pluck<U>(Iterable<String> fieldNames) => null;

  @override
  Future<Iterable<UpdateResult>> updateAll(Map<String, dynamic> fields) => null;
}