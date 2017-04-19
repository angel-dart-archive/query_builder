import 'repository.dart';

abstract class DataStore<T> {
  Repository<T> repository(String tableName);
}