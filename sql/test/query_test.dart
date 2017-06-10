import 'package:query_builder/query_builder.dart';
import 'package:query_builder_sql/query_builder_sql.dart';
import 'package:test/test.dart';
import 'common.dart';

AbstractRepositoryQuery query() => new AbstractRepositoryQuery('foo');

main() {
  group('select', () {
    test('select all', () {
      expect(query(), equalsSql('SELECT * FROM `foo`;'));
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
      });

      test('whereNull', () {
        expect(query().whereNull('bar'),
            equalsSql('SELECT * FROM `foo` WHERE `bar` = NULL;'));
      });
    });

    group('or', () {
      test('simple', () {
        var q = query().where('one', 1).or(query().where('two', 2));
        expect(
            q, equalsSql('SELECT * FROM `foo` WHERE `one` = 1 OR `two` = 2;'));
      });
    });
  });

  test('skip', () {
    expect(query().skip(5), equalsSql('SELECT * FROM `foo` OFFSET 5;'));
  });

  test('take', () {
    expect(query().take(5), equalsSql('SELECT * FROM `foo` LIMIT 5;'));
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

  test('union', () {
    expect(query().union(new AbstractRepositoryQuery('bar')),
        equalsSql('SELECT * FROM `foo` UNION (SELECT * FROM `bar`);'));
    expect(query().union(new AbstractRepositoryQuery('bar'), UnionType.ALL),
        equalsSql('SELECT * FROM `foo` UNION ALL (SELECT * FROM `bar`);'));
  });
}
