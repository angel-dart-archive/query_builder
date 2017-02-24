import 'package:intl/intl.dart' show DateFormat;
import 'package:query_builder/query_builder.dart';
import 'package:query_builder_in_memory/query_builder_in_memory.dart';
import 'common.dart';

final DateFormat _fmt = new DateFormat.yMMMMd();

String describeEvent(Map<String, dynamic> event) {
  String name = event['name'];
  DateTime date = event['date'];
  return '$name (${_fmt.format(date)})';
}

main() async {
  var store = new InMemoryDataStore();
  var calendar = store.repository('calendar');

  await calendar.insertAll([
    {'name': 'Y2K', 'date': new DateTime(2000, 1, 1)},
    {'name': 'Trump Inauguration', 'date': new DateTime(2017, 1, 20)},
    {'name': 'Death of Michael Jackson', 'date': new DateTime(2009, 05, 29)}
  ]);

  print('Total number of events: ' + (await calendar.all().count()).toString());

  print('\nAll events in calendar, beginning with the most recent:');
  await calendar
      .all()
      .orderBy('date', OrderBy.DESCENDING)
      .get()
      .map<String>(describeEvent)
      .forEach(printBullet);

  print('\nAll events for this year:');
  await calendar
      .all()
      .whereYear('date', new DateTime.now().year)
      .get()
      .map<String>(describeEvent)
      .forEach(printBullet);

  print(
      '\nAll events that took place or will take place in the current month:');
  var thisMonth = await calendar
      .all()
      .whereMonth('date', new DateTime.now().month)
      .get()
      .map<String>(describeEvent)
      .toList();

  if (thisMonth.isEmpty)
    printBullet('<none>');
  else
    thisMonth.forEach(printBullet);

  print('\nAll events that took place or will take place in January:');
  await calendar
      .all()
      .whereMonth('date', 1)
      .get()
      .map<String>(describeEvent)
      .forEach(printBullet);
}
