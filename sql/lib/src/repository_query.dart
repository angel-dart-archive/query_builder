import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:query_builder/query_builder.dart';

final RegExp _dashComment = new RegExp(r'--+'),
    _commentStart = new RegExp(r'/\*'),
    // i.e. a malicious user tries to place a semicolon and inject another query
    _multiQuery = new RegExp(r';[^$]*');

abstract class SqlRepositoryQuery<T> extends RepositoryQuery<T> {
  final String tableName;
  final List<String> from = [];
  final Map<String, String> selectFields = {};
  final Map<String, String> whereFields = {};
  final List<String> orConditions = [], notConditions = [];
  final Map<String, Tuple3<JoinType, String, String>> joins = {};
  final Map<String, UnionType> unions = {};
  final Map<String, OrderBy> sort = {};
  String groupByField, rawQuery;
  int limit, offset;
  bool isDistinct = false;

  SqlRepositoryQuery(this.tableName);

  static String sanitizeString(String fieldName) {
    return fieldName
        .replaceAll(_multiQuery, '')
        .replaceAll(_commentStart, '')
        .replaceAll(_dashComment, '')
        // If you're running through package:query_builder, you shouldn't need commas anyways
        .replaceAll(',', '')
        .replaceAll('\'', '\\\'')
        // Escape backslashes
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        // Prevent null-byte
        .replaceAll('\u0000', '');
  }

  /// Transforms a value into a sanitized String suitable for SQL.
  static String safeStringify(value) {
    if (value is num)
      return value.toString();
    else if (value is DateTime)
      return dateToSql(value, true);
    else if (value == null) return 'NULL';
    return '`' + sanitizeString(value.toString()) + '`';
  }

  static String intToString(int n) {
    if (n < 10 && n >= 0)
      return '0$n';
    else
      return n.toString();
  }

  static String dateToSql(DateTime dt, bool time) {
    if (time) {
      return "'${intToString(dt.year)}-${intToString(dt.month)}-${intToString(dt.day)} ${intToString(dt.hour)}:${intToString(dt.minute)}:${intToString(dt.second)}'";
    } else
      return "'${intToString(dt.year)}-${intToString(dt.month)}-${intToString(dt.day)}'";
  }

  Future<int> executeAsInt(String query);

  Future<num> executeAsNum(String query);

  String toSql({bool semicolon: true}) {
    if (rawQuery != null) return rawQuery;

    var buf = new StringBuffer('SELECT');

    if (isDistinct == true) buf.write(' DISTINCT');

    // Select fields or *
    if (selectFields.isEmpty)
      buf.write(' *');
    else {
      int i = 0;

      for (var key in selectFields.keys) {
        if (i++ > 0) buf.write(',');
        var v = selectFields[key];
        if (v == key)
          buf.write(' `$key`');
        else
          buf.write(' `$key` AS `$v`');
      }
    }

    buf.write(' FROM ');

    if (from.isEmpty)
      buf.write('`${sanitizeString(tableName)}`');
    else {
      for (int i = 0; i < from.length; i++) {
        if (i > 0) buf.write(', ');
        var key = from[i];
        if (key.startsWith('!'))
          buf.write(key.substring(1));
        else
          buf.write('`$key`');
      }
    }

    // Where
    var whereCond = toWhereCondition();
    if (whereCond != null) buf.write(' WHERE $whereCond');

    // Group by
    if (groupByField != null) buf.write(' GROUP BY `$groupByField`');

    // Order by
    for (var key in sort.keys) {
      var v = orderByToString(sort[key]);

      if (key == '*') {
        buf.write(' ORDER BY $v');
        break;
      } else
        buf.write(' ORDER BY `$key` $v');
    }

    // Limit, offset
    if (offset != null) buf.write(' OFFSET $offset');
    if (limit != null) buf.write(' LIMIT $limit');

    // Joins
    for (var table in joins.keys) {
      var tuple = joins[table];
      var type = joinTypeToString(tuple.item1);
      buf.write(' $type JOIN `$table` ON `${tuple.item2}` = `${tuple.item3}`');
    }

    // Unions
    for (var query in unions.keys) {
      var type = unionTypeToString(unions[query]);
      buf.write(' $type ($query)');
    }

    if (semicolon != false) buf.write(';');
    return buf.toString();
  }

  String toWhereCondition() {
    var str = '';

    if (whereFields.isEmpty) {
      return compileOrConditions();
    } else {
      int i = 0;

      whereFields.forEach((k, v) {
        if (i++ > 0) str += ' AND ';
        var kk = k.startsWith('!') ? k.substring(1) : '`$k`';
        str += '$kk $v';
      });

      var or = compileOrConditions();
      if (or != null) str += ' OR $or';
    }

    return str;
  }

  String compileOrConditions() {
    if (orConditions.isEmpty && notConditions.isEmpty) return null;
    var str = '';

    for (int i = 0; i < orConditions.length; i++) {
      var cond = '${orConditions[i]}';
      if (i > 0) str += ' OR ';
      str += cond;
    }

    // Maybe add not
    if (orConditions.isNotEmpty && notConditions.isNotEmpty)
      str += ' AND NOT ';
    else if (notConditions.isNotEmpty) str += 'NOT ';

    for (int i = 0; i < notConditions.length; i++) {
      var cond = '${notConditions[i]}';
      if (i > 0) str += ' AND NOT ';
      str += cond;
    }

    return str;
  }

  @override
  Future<num> average(String fieldName) {
    var escaped = sanitizeString(fieldName);
    var query = toSql(semicolon: false);
    return executeAsNum('SELECT AVG(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  Future<int> count() {
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT COUNT(*) FROM ($query) AS `value`;');
  }

  @override
  RepositoryQuery<T> distinct(Iterable<String> fieldNames) {
    return this
      ..isDistinct = true
      ..select(fieldNames);
  }

  @override
  RepositoryQuery<T> groupBy(String fieldName) {
    return this..groupByField = sanitizeString(fieldName);
  }

  @override
  RepositoryQuery<T> inRandomOrder() {
    return this..sort['*'] = OrderBy.RANDOM;
  }

  @override
  Future<num> max(String fieldName) {
    var escaped = sanitizeString(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT MAX(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  Future<num> min(String fieldName) {
    var escaped = sanitizeString(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT MIN(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  RepositoryQuery<T> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]) {
    if (orderBy == OrderBy.RANDOM)
      throw new UnsupportedError(
          'Cannot order by `OrderBy.RANDOM`. Use `inRandomOrder()` instead.');
    return this..sort[sanitizeString(fieldName)] = orderBy ?? OrderBy.ASCENDING;
  }

  @override
  RepositoryQuery<T> select(Iterable selectors) {
    for (var selector in selectors) {
      if (selector is String) {
        var escaped = sanitizeString(selector);
        selectFields[escaped] = escaped;
      } else if (selector is Map) {
        selector.forEach((k, v) {
          var escaped = sanitizeString(k.toString());
          selectFields[escaped] = sanitizeString(v.toString());
        });
      } else
        throw new ArgumentError('Cannot select $selector in a SQL query.');
    }

    return this;
  }

  @override
  RepositoryQuery<T> skip(int count) {
    return this..offset = count;
  }

  @override
  Future<num> sum(String fieldName) {
    var escaped = sanitizeString(fieldName);
    var query = toSql(semicolon: false);
    return executeAsInt('SELECT SUM(`$escaped`) FROM ($query) AS `value`;');
  }

  @override
  RepositoryQuery<T> take(int count) {
    return this..limit = count;
  }

  @override
  RepositoryQuery<T> join(
      String otherTable, String nearColumn, String farColumn,
      [JoinType joinType = JoinType.INNER]) {
    return this
      ..joins[sanitizeString(otherTable)] =
          new Tuple3<JoinType, String, String>(joinType ?? JoinType.INNER,
              sanitizeString(nearColumn), sanitizeString(farColumn));
  }

  @override
  RepositoryQuery<T> union(RepositoryQuery<T> other,
      [UnionType type = UnionType.NORMAL]) {
    if (other is SqlRepositoryQuery<T>) {
      return this
        ..unions[other.toSql(semicolon: false)] = type ?? UnionType.NORMAL;
    } else
      throw new ArgumentError(
          'Can only union a SQL query with another SQL query.');
  }

  @override
  RepositoryQuery<T> whereBetween(String fieldName, lower, upper) {
    var f = safeStringify(lower), s = safeStringify(upper);
    return this..whereFields[sanitizeString(fieldName)] = 'BETWEEN $f AND $s';
  }

  @override
  RepositoryQuery<T> whereDate(String fieldName, DateTime date,
      {bool time: true}) {
    return this
      ..whereFields[sanitizeString(fieldName)] =
          '= ' + dateToSql(date, time != false);
  }

  @override
  RepositoryQuery<T> whereDay(String fieldName, int day) {
    return this..whereFields['!DAY(`${sanitizeString(fieldName)}`)'] = '= $day';
  }

  @override
  RepositoryQuery<T> whereEquality(String fieldName, value, Equality equality) {
    String condition, escaped = sanitizeString(fieldName);

    switch (equality) {
      case Equality.EQUAL:
        condition = '= ' + safeStringify(value);
        break;
      case Equality.NOT_EQUAL:
        condition = '!= ' + safeStringify(value);
        break;
      case Equality.LESS_THAN:
        condition = '< ' + safeStringify(value);
        break;
      case Equality.LESS_THAN_OR_EQUAL_TO:
        condition = '<= ' + safeStringify(value);
        break;
      case Equality.GREATER_THAN:
        condition = '> ' + safeStringify(value);
        break;
      case Equality.GREATER_THAN_OR_EQUAL_TO:
        condition = '>= ' + safeStringify(value);
        break;
      case Equality.LESS_THAN_OR_GREATER_THAN:
        var str = safeStringify(value);
        whereFields[escaped] = '< ' + str;
        return this..orConditions.add('`$escaped` > $str');
    }

    return this..whereFields[escaped] = condition;
  }

  @override
  RepositoryQuery<T> whereIn(String fieldName, Iterable values) {
    var f = values.map(safeStringify).join(', ');
    return this..whereFields[sanitizeString(fieldName)] = 'IN ($f)';
  }

  @override
  RepositoryQuery<T> whereLike(String fieldName, value) {
    return this
      ..whereFields[sanitizeString(fieldName)] = 'LIKE ' + safeStringify(value);
  }

  @override
  RepositoryQuery<T> whereMonth(String fieldName, int month) {
    return this
      ..whereFields['!MONTH(`${sanitizeString(fieldName)}`)'] = '= $month';
  }

  @override
  RepositoryQuery<T> whereNotBetween(String fieldName, lower, upper) {
    var f = safeStringify(lower), s = safeStringify(upper);
    return this
      ..whereFields[sanitizeString(fieldName)] = 'NOT BETWEEN $f AND $s';
  }

  @override
  RepositoryQuery<T> whereNotIn(String fieldName, Iterable values) {
    var f = values.map(safeStringify).join(', ');
    return this..whereFields[sanitizeString(fieldName)] = 'NOT IN ($f)';
  }

  @override
  RepositoryQuery<T> whereYear(String fieldName, int year) {
    return this
      ..whereFields['!YEAR(`${sanitizeString(fieldName)}`)'] = '= $year';
  }

  @override
  RepositoryQuery<T> selfJoin(String t1, String t2) {
    var escaped = sanitizeString(tableName);
    return this
      ..from
          .addAll([t1, t2].map(sanitizeString).map((t) => '!`$escaped` `$t`'));
  }

  @override
  RepositoryQuery<T> or(RepositoryQuery<T> other) {
    if (other is SqlRepositoryQuery<T>) {
      return this..orConditions.add(other.toWhereCondition());
    } else
      throw new ArgumentError(
          'SQL queries can only perform an \'OR\' on another SQL query.');
  }

  @override
  RepositoryQuery<T> not(RepositoryQuery<T> other) {
    if (other is SqlRepositoryQuery<T>) {
      return this..notConditions.add(other.toWhereCondition());
    } else
      throw new ArgumentError(
          'SQL queries can only perform an \'NOT\' on another SQL query.');
  }
}
