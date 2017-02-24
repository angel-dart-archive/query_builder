import 'package:query_builder/query_builder.dart';
import 'package:query_builder_in_memory/query_builder_in_memory.dart';
import 'common.dart';

main() async {
  var store = new InMemoryDataStore();
  var todos = store.repository('todos');

  await todos.insertAll([
    {'text': 'Clean your room!', 'completed': false},
    {'text': 'Overeat', 'completed': true},
    {'text': 'Get a life...', 'completed': false},
    {'text': 'Lose your keys', 'completed': true},
    {'text': 'Buy a new car', 'completed': false}
  ]);

  print('2 todos after an intensive query:');
  (await todos
          .all()
          .orderBy('text')
          .skip(1)
          .take(2)
          .orderBy('id', OrderBy.DESCENDING)
          .pluck<String>(['text']))
      .forEach(printBullet);

  print('\nIn random order:');
  await todos.all().inRandomOrder().get().forEach(printBullet);

  print('\nWhat is left to do:');
  await todos
      .where('completed', false)
      .map<String>((m) => m['text']) // Basically `pluck`
      .asStream()
      .expand((li) => li)
      .forEach(printBullet);

  print('\nHighest ID:');
  printBullet(await todos.all().max('id'));
}
