import 'dart:async';
import 'results/results.dart';
import 'change_event.dart';
import 'equality.dart';
import 'repository_query.dart';
import 'single_query.dart';

abstract class Repository<T> {
  RepositoryQuery<T> all();

  Stream<ChangeEvent<T>> changes();

  Future close();

  Future<DeletionResult<T>> delete(String id) => find(id).delete();

  Future<DeletionResult<T>> deleteAll() => all().delete();

  Future<DeletionResult<T>> deleteWhere(String fieldName, value) =>
      where(fieldName, value).delete();

  Future<DeletionResult<T>> deleteWhereEquality(
          String fieldName, value, Equality equality) =>
      whereEquality(fieldName, value, equality).delete();

  SingleQuery<T> find(String id) => all().where('id', id).first();

  Future<InsertionResult> insert(T data);

  Future<InsertionResult> insertAll(Iterable<T> data);

  RepositoryQuery<T> raw(query);

  RepositoryQuery<T> where(String fieldName, value) => all().where(fieldName, value);

  RepositoryQuery<T> whereEquality(String fieldName, value, Equality equality) =>
      all().whereEquality(fieldName, value, equality);
}
