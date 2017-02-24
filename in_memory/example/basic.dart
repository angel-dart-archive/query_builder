import 'package:query_builder/query_builder.dart';
import 'package:query_builder_in_memory/query_builder_in_memory.dart';

main() async {
  var store = new InMemoryDataStore();
  var basic = store.repository('basic');

  var count = await basic.all().count();
  print('Count: $count');

  basic.all().chunk(100, (items) {
    print('Got a chunk: $items');
  });

  print(await basic.all().orderBy('text', OrderBy.DESCENDING).count());
}
