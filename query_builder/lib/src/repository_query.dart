import 'dart:async';
import 'results/results.dart';
import 'change_event.dart';
import 'equality.dart';
import 'order_by.dart';
import 'single_query.dart';

abstract class RepositoryQuery<T> {
  Stream<T> get();

  Future<num> average(String fieldName);

  Stream<ChangeEvent<T>> changes();

  Future<int> count();

  Future<DeletionResult<T>> delete();

  RepositoryQuery<T> distinct();

  SingleQuery<T> first();

  RepositoryQuery<T> groupBy(String fieldName);

  RepositoryQuery<T> inRandomOrder();

  RepositoryQuery<T> latest([String fieldName = 'created_at']) =>
      orderBy(fieldName, OrderBy.DESCENDING);

  // TODO: Join

  /// Prevents any other queries from being run on the repository until this one
  /// is resolved.
  RepositoryQuery<T> mutex();

  RepositoryQuery<T> orderBy(String fieldName,
      [OrderBy orderBy = OrderBy.ASCENDING]);

  Future<List<U>> map<U>(U convert(T t)) => get().map<U>(convert).toList();

  Future<num> max(String fieldName);

  RepositoryQuery<T> oldest([String fieldName = 'created_at']) =>
      orderBy(fieldName, OrderBy.ASCENDING);

  Future<Iterable<U>> pluck<U>(Iterable<String> fieldNames);

  RepositoryQuery<T> select(Iterable selectors);

  RepositoryQuery<T> skip(int count);

  Future<num> sum(String fieldName);

  RepositoryQuery<T> take(int count);

  RepositoryQuery<T> union(RepositoryQuery<T> other);

  RepositoryQuery<T> unionAll(RepositoryQuery<T> other);

  Future<Iterable<UpdateResult<T>>> updateAll(Map<String, dynamic> fields);

  RepositoryQuery<T> when(
      bool condition, RepositoryQuery<T> ifTrue(RepositoryQuery<T> query),
      [RepositoryQuery<T> ifFalse(RepositoryQuery<T> query)]) {
    if (condition == true)
      return ifTrue(this);
    else if (ifFalse != null) return ifFalse(this);
    return this;
  }

  WhereQuery<T> where(String fieldName, value) =>
      whereEquality(fieldName, value, Equality.EQUAL);

  WhereQuery<T> whereNot(String fieldName, value) =>
      whereEquality(fieldName, value, Equality.NOT_EQUAL);

  WhereQuery<T> whereBetween(String fieldName, Iterable values);

  WhereQuery<T> whereNotBetween(String fieldName, Iterable values);

  WhereQuery<T> whereColumn(String first, String second);

  WhereQuery<T> whereDate(String fieldName, DateTime date);

  WhereQuery<T> whereDay(String fieldName, int day);

  WhereQuery<T> whereMonth(String fieldName, int month);

  WhereQuery<T> whereYear(String fieldName, int year);

  WhereQuery<T> whereIn(String fieldName, Iterable values);

  WhereQuery<T> whereNotIn(String fieldName, Iterable values);

  WhereQuery<T> whereEquality(String fieldName, value, Equality equality);

  WhereQuery<T> whereExists(builder(RepositoryQuery<T> query));

  WhereQuery<T> whereLike(String fieldName, value);

  WhereQuery<T> whereJson(String fieldName, value);

  WhereQuery<T> whereNull(String fieldName);

  WhereQuery<T> whereNotNull(String fieldName);

  Future<Iterable> chunk(int threshold, FutureOr callback(List<T> items)) {
    var c = new Completer<List>();
    StreamSubscription<T> sub;
    List results = [];
    List<T> items = [];

    sub = get().listen(
        (T item) async {
          items.add(item);

          if (items.length >= threshold) {
            var result = await callback(items);
            results.add(result);
            items.clear();

            if (result == false) await sub.cancel();
          }
        },
        cancelOnError: true,
        onDone: () async {
          if (items.isNotEmpty) {
            results.add(await callback(items));
            items.clear();
          }

          c.complete(results);
        },
        onError: c.completeError);

    return c.future;
  }
}

abstract class WhereQuery<T> extends RepositoryQuery<T> {
  // TODO: Or queries
}
