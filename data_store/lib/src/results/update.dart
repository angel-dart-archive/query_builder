abstract class UpdateResult<T> {
  List<String> get updatedIds;
  List<T> get updatedItems;
  int get numberupdated;
  bool get successful;
}