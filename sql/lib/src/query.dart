import 'package:query_builder/query_builder.dart';

/// Represents a SQL query, and can be used to generate database queries.
abstract class SQLQuery {
  /// Returns `true` if the nature of this query is to modify the contents of the database.
  bool get isWrite;

  /// The action to run on the database. Ex. `select`, `insert`, etc.
  String get verb;

  /// Joins the results of this query with those of the [other] query.
  SQLQuery join(SQLQuery other);

  /// Filters the query to also return results matching the [other] query.
  SQLQuery or(SQLQuery other);

  /// Orders the results by [fieldName], whether ascending or descending.
  ///
  /// [mode] defaults to [OrderBy.ASCENDING].
  SQLQuery orderBy(String fieldName, [OrderBy mode = OrderBy.ASCENDING]);

  /// Filters the query to return only results matching the desired [fields].
  SQLQuery where(Map<String, dynamic> fields);

  /// Filters the query to return only results *not* matching the desired [fields].
  SQLQuery whereNot(Map<String, dynamic> fields);

  /// Produces a SQL query condition suitable for use in a WHERE clause.
  String toCondition();

  /// Builds a safe SQL query.
  String toSql();
}