import 'package:data_store_in_memory/data_store_in_memory.dart';

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

  await todos.where('completed', false).get().forEach(print);
}
