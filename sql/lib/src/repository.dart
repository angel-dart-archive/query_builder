import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'query.dart';

abstract class SqlRepository<T> extends Repository<T> {
  String get databaseName;

  @override
  Stream<ChangeEvent<T>> changes() => throw new UnsupportedError(
      'Cannot listen for changes on a $databaseName table!');
}
