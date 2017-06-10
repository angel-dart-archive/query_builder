import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:query_builder/src/results/delete.dart';
import 'package:query_builder/src/results/update.dart';
import 'package:query_builder/src/single_query.dart';
import 'package:query_builder_sql/query_builder_sql.dart';

Map<String, dynamic> rowToMap(List row, List<String> selectFields) {
  Map<String, dynamic> result = {};

  for (int i = 0; i < selectFields.length; i++) {
    result[selectFields[i]] = row[i];
  }

  return result;
}

class PostgresSqlRepositoryQuery
    extends SqlRepositoryQuery<Map<String, dynamic>> {
  final PostgreSQLConnection connection;

  PostgresSqlRepositoryQuery(this.connection, String tableName)
      : super(tableName);

  @override
  Future<DeletionResult<Map<String, dynamic>>> delete() {
    // TODO: implement delete
  }

  @override
  Future<int> executeAsInt(String query) {
    return connection.query(query).then((result) {
      return result[0][0];
    });
  }

  @override
  Future<num> executeAsNum(String query) {
    return connection.query(query).then((result) {
      return result[0][0];
    });
  }

  @override
  SingleQuery<Map<String, dynamic>> first() {
    // TODO: implement first
  }

  @override
  Stream<Map<String, dynamic>> get() {
    var ctrl = new StreamController<Map<String, dynamic>>();

    connection.query(toSql(semicolon: true)).then((result) {
      result
          .map((row) => rowToMap(row, selectFields.values.toList()))
          .forEach(ctrl.add);
      ctrl.close();
    }).catchError(ctrl.addError);

    return ctrl.stream;
  }

  @override
  Future<Iterable> pluck<U>(Iterable<String> fieldNames) {
    // TODO: implement pluck
  }

  @override
  Future<Iterable<UpdateResult<Map<String, dynamic>>>> updateAll(
      Map<String, dynamic> fields) {
    // TODO: implement updateAll
  }
}
