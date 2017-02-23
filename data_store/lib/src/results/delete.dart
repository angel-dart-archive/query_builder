abstract class DeletionResult<T> {
  List<String> get removedIds;
  List<T> get removedItems;
  int get numberRemoved;
  bool get successful;
}