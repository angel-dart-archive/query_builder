import 'dart:async';
import 'package:query_builder/query_builder.dart';
import 'package:query_builder_sql/query_builder_sql.dart';
import 'package:test/test.dart';
import 'common.dart';

TestQuery query() => new TestQuery('foo');

main() {
  group('select', () {
    test('select all', () {
      expect(query(), equalsSql('SELECT * FROM `foo`;'));
    });

    test('custom from', () {
      var q = query()..from.add('bar');
      expect(q, equalsSql('SELECT * FROM `bar`;'));
    });

    test('alias', () {
      expect(
          query().select([
            {'bar': 'baz'}
          ]),
          equalsSql('SELECT `bar` AS `baz` FROM `foo`;'));
      expect(
          query().select([
            {'bar': 'baz', 'a': 'b'},
            {'c': 'd'}
          ]),
          equalsSql(
              'SELECT `bar` AS `baz`, `a` AS `b`, `c` AS `d` FROM `foo`;'));
    });

    test('distinct one', () {
      expect(query().distinct(['one']),
          equalsSql('SELECT DISTINCT `one` FROM `foo`;'));
    });

    test('distinct multiple', () {
      expect(query().distinct(['one', 'two', 'three']),
          equalsSql('SELECT DISTINCT `one`, `two`, `three` FROM `foo`;'));
    });

    group('where', () {
      test('equal', () {
        expect(query().where('one', 1),
            equalsSql('SELECT * FROM `foo` WHERE `one` = 1;'));
        expect(query().whereNot('one', 1),
            equalsSql('SELECT * FROM `foo` WHERE `one` != 1;'));
        expect(query().whereEquality('one', 1, Equality.LESS_THAN),
            equalsSql('SELECT * FROM `foo` WHERE `one` < 1;'));
        expect(query().whereEquality('one', 1, Equality.LESS_THAN_OR_EQUAL_TO),
            equalsSql('SELECT * FROM `foo` WHERE `one` <= 1;'));
        expect(query().whereEquality('one', 1, Equality.GREATER_THAN),
            equalsSql('SELECT * FROM `foo` WHERE `one` > 1;'));
        expect(
            query().whereEquality('one', 1, Equality.GREATER_THAN_OR_EQUAL_TO),
            equalsSql('SELECT * FROM `foo` WHERE `one` >= 1;'));
        expect(
            query().whereEquality('one', 1, Equality.LESS_THAN_OR_GREATER_THAN),
            equalsSql('SELECT * FROM `foo` WHERE `one` < 1 OR `one` > 1;'));
      });

      test('whereBetween', () {
        expect(
            query().whereBetween('percent', 1, 100),
            equalsSql(
                'SELECT * FROM `foo` WHERE `percent` BETWEEN 1 AND 100;'));
        expect(
            query().whereNotBetween('percent', 1, 100),
            equalsSql(
                'SELECT * FROM `foo` WHERE `percent` NOT BETWEEN 1 AND 100;'));
      });

      test('whereIn', () {
        expect(query().whereIn('letter', ['a', 'b', 2]),
            equalsSql('SELECT * FROM `foo` WHERE `letter` IN (`a`, `b`, 2);'));
        expect(
            query().whereNotIn('letter', ['a', 'b', 2]),
            equalsSql(
                'SELECT * FROM `foo` WHERE `letter` NOT IN (`a`, `b`, 2);'));
      });

      test('whereDate', () {
        var mjDeath = new DateTime(2009, 05, 29, 12, 21);
        expect(
            query().whereDate('created_at', mjDeath, time: false),
            equalsSql(
                "SELECT * FROM `foo` WHERE `created_at` = '2009-05-29';"));

        expect(
            query().whereDate('created_at', mjDeath),
            equalsSql(
                "SELECT * FROM `foo` WHERE `created_at` = '2009-05-29 12:21:00';"));

        expect(
            query().where('created_at', mjDeath),
            equalsSql(
                "SELECT * FROM `foo` WHERE `created_at` = '2009-05-29 12:21:00';"));

        expect(query().whereDay('created_at', 3),
            equalsSql('SELECT * FROM `foo` WHERE DAY(`created_at`) = 3;'));

        expect(query().whereMonth('created_at', 3),
            equalsSql('SELECT * FROM `foo` WHERE MONTH(`created_at`) = 3;'));

        expect(query().whereYear('created_at', 3),
            equalsSql('SELECT * FROM `foo` WHERE YEAR(`created_at`) = 3;'));
      });

      test('whereNull', () {
        expect(query().whereNull('bar'),
            equalsSql('SELECT * FROM `foo` WHERE `bar` = NULL;'));
      });

      test('whereLike', () {
        expect(query().whereLike('title', '*foo*'),
            equalsSql('SELECT * FROM `foo` WHERE `title` LIKE `*foo*`;'));
      });
    });

    group('or', () {
      test('simple', () {
        var q = query().where('one', 1).or(query().where('two', 2));
        expect(
            q, equalsSql('SELECT * FROM `foo` WHERE `one` = 1 OR `two` = 2;'));
      });
    });

    group('not', () {
      test('simple', () {
        var q = query().where('one', 1).not(query().where('two', 2));
        expect(q,
            equalsSql('SELECT * FROM `foo` WHERE `one` = 1 OR NOT `two` = 2;'));
      });

      test('multiple not', () {
        var q = query()
            .where('one', 1)
            .not(query().where('two', 2))
            .not(query().where('three', 3));
        expect(
            q,
            equalsSql(
                'SELECT * FROM `foo` WHERE `one` = 1 OR NOT `two` = 2 AND NOT `three` = 3;'));
      });

      test('or+not', () {
        var q = query()
            .where('number', 1)
            .or(query().where('number', 2))
            .not(query().where('number', 3));
        expect(
            q,
            equalsSql(
                'SELECT * FROM `foo` WHERE `number` = 1 OR `number` = 2 AND NOT `number` = 3;'));
      });
    });
  });

  test('skip', () {
    expect(query().skip(5), equalsSql('SELECT * FROM `foo` OFFSET 5;'));
  });

  test('take', () {
    expect(query().take(5), equalsSql('SELECT * FROM `foo` LIMIT 5;'));
  });

  test('group by', () {
    expect(query().groupBy('bar'),
        equalsSql('SELECT * FROM `foo` GROUP BY `bar`;'));

    // Overwrite
    expect(query().groupBy('bar').groupBy('baz'),
        equalsSql('SELECT * FROM `foo` GROUP BY `baz`;'));
  });

  test('order by', () {
    expect(query().inRandomOrder(),
        equalsSql('SELECT * FROM `foo` ORDER BY RAND();'));
    expect(query().orderBy('bar'),
        equalsSql('SELECT * FROM `foo` ORDER BY `bar` ASC;'));
    expect(query().orderBy('bar', OrderBy.DESCENDING),
        equalsSql('SELECT * FROM `foo` ORDER BY `bar` DESC;'));
  });

  test('join', () {
    expect(query().join('A', 'B', 'C'),
        equalsSql('SELECT * FROM `foo` INNER JOIN `A` ON `B` = `C`;'));
    expect(query().join('A', 'B', 'C', JoinType.LEFT),
        equalsSql('SELECT * FROM `foo` LEFT JOIN `A` ON `B` = `C`;'));
    expect(query().join('A', 'B', 'C', JoinType.RIGHT),
        equalsSql('SELECT * FROM `foo` RIGHT JOIN `A` ON `B` = `C`;'));
    expect(query().join('A', 'B', 'C', JoinType.FULL_OUTER),
        equalsSql('SELECT * FROM `foo` FULL OUTER JOIN `A` ON `B` = `C`;'));
  });

  test('self join', () {
    expect(query().selfJoin('a', 'b').where('c', 'd'),
        equalsSql('SELECT * FROM `foo` `a`, `foo` `b` WHERE `c` = `d`;'));
  });

  test('union', () {
    expect(query().union(new AbstractRepositoryQuery('bar')),
        equalsSql('SELECT * FROM `foo` UNION (SELECT * FROM `bar`);'));
    expect(query().union(new AbstractRepositoryQuery('bar'), UnionType.ALL),
        equalsSql('SELECT * FROM `foo` UNION ALL (SELECT * FROM `bar`);'));
  });

  group('computations', () {
    test('average', () async {
      var q = query();
      await q.average('bar');
      expect(
          q,
          equalsSql(
              'SELECT AVG(`bar`) FROM (SELECT * FROM `foo`) AS `value`;'));
    });

    test('sum', () async {
      var q = query();
      await q.sum('bar');
      expect(
          q,
          equalsSql(
              'SELECT SUM(`bar`) FROM (SELECT * FROM `foo`) AS `value`;'));
    });

    test('min', () async {
      var q = query();
      await q.min('bar');
      expect(
          q,
          equalsSql(
              'SELECT MIN(`bar`) FROM (SELECT * FROM `foo`) AS `value`;'));
    });
    test('max', () async {
      var q = query();
      await q.max('bar');
      expect(
          q,
          equalsSql(
              'SELECT MAX(`bar`) FROM (SELECT * FROM `foo`) AS `value`;'));
    });

    test('count', () async {
      var q = query();
      await q.count();
      expect(q,
          equalsSql('SELECT COUNT(*) FROM (SELECT * FROM `foo`) AS `value`;'));
    });
  });

  group('exceptions', () {
    test('union/or/not with invalid arg', () {
      expect(() => query().union(null), throwsArgumentError);
      expect(() => query().or(null), throwsArgumentError);
      expect(() => query().not(null), throwsArgumentError);
    });

    test('orderBy random', () {
      expect(
          () => query().orderBy('bar', OrderBy.RANDOM), throwsUnsupportedError);
    });

    test('invalid selector', () {
      expect(() => query().select([4]), throwsArgumentError);
    });
  });
}

class TestQuery extends AbstractRepositoryQuery {
  TestQuery(String tableName) : super(tableName);

  @override
  Future<num> executeAsNum(String query) => executeAsInt(query);

  @override
  Future<int> executeAsInt(String query) async {
    rawQuery = query;
    return null;
  }
}
