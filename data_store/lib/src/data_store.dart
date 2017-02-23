import 'repository.dart';

abstract class DataStore {
  Repository<T> repository<T>(String tableName);
}