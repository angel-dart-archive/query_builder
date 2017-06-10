import 'dart:async';
import 'package:matcher/matcher.dart';
import 'package:query_builder/query_builder.dart';
import 'package:query_builder_sql/query_builder_sql.dart';

Matcher equalsSql(String sql) => new _EqualsSql(sql);

class _EqualsSql extends Matcher {
  final String expectedSql;

  _EqualsSql(this.expectedSql);

  @override
  Description describe(Description description) =>
      description.add('generates the SQL query "$expectedSql"');

  @override
  bool matches(SqlRepositoryQuery item, Map matchState) {
    var sql = item.toSql();
    print('Generated SQL: $sql');
    return equals(expectedSql).matches(sql, matchState);
  }
}
