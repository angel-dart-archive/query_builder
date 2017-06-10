import 'dart:async';
import 'results/results.dart';

abstract class SingleQuery<T> {
  Future<T> get();

  SingleQuery<T> decrement(String fieldName,
          [int amount = 1, Map<String, dynamic> additionalFields = const {}]) =>
      increment(fieldName, amount * -1, additionalFields ?? {});

  Future<DeletionResult<T>> delete();

  SingleQuery<T> increment(String fieldName,
      [int amount = 1, Map<String, dynamic> additionalFields = const {}]);

  Future<UpdateResult<T>> update(Map<String, dynamic> fields);
}
