import 'package:query_builder_sql/query_builder_sql.dart';
import 'package:test/test.dart';
import 'common.dart';

AbstractRepositoryQuery query() => new AbstractRepositoryQuery('foo');

main() {
  group('select', () {
    test('select all', () {
      expect(query(), equalsSql('SELECT * FROM `foo`;'));
    });

    test('distinct one', () {
      expect(query().distinct('one'),
          equalsSql('SELECT DISTINCT `one` FROM `foo`;'));
    });

    test('distinct multiple', () {
      expect(
          query().distinct('one').distinct('two').distinct('three'),
          equalsSql(
              'SELECT DISTINCT `one`, `two`, `three` FROM `foo`;'));
    });

    group('where', () {
      group('equal', () {
        test('number', () {
          expect(query().where('one', 1),
              equalsSql('SELECT * FROM `foo` WHERE `one` = 1;'));
        });
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
}
