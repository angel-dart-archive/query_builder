import 'dart:async';
import 'dart:io';
import 'package:angel_diagnostics/angel_diagnostics.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_query_builder/angel_query_builder.dart';
import 'package:query_builder_in_memory/query_builder_in_memory.dart';

main() async {
  var app = await createServer();
  var server = await app.startServer(InternetAddress.ANY_IP_V4, 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}

Future<Angel> createServer() async {
  var app = new Angel();
  var store = new InMemoryDataStore();
  app.use('/todos',
      new RepositoryService(store.repository('todos')));

  // Insert some boilerplate data
  var service = app.service('todos') as HookedService;
  await service.create({'hello': 'world'});
  await service.create({'angel': 'framework'});
  await service.create({'michael': 'jackson'});

  app.errorHandler = (AngelHttpException e, req, ResponseContext res) async {
    res
      ..write('${e.statusCode}: ${e.message}')
      ..end();
  };

  app.fatalErrorStream.listen((e) {
    stderr..writeln('Fatal: ${e.error}')..writeln(e.stack);
  });

  await app.configure(logRequests());
  return app;
}
