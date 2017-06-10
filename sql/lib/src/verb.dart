/// Contains a collection of commonly-used SQL verbs.
abstract class SQLQueryVerb {
  static const String SELECT = 'select',
      INSERT = 'insert',
      UPDATE = 'update',
      DELETE = 'delete';

  static const List<String> READ_ONLY = const [SELECT];
  static const List<String> WRITE_ONLY = const [INSERT, UPDATE, DELETE];
}
