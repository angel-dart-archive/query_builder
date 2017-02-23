abstract class CreationResult<T> {
  List<String> get createdIds;
  List<T> get createdItems;
  int get numberCreated;
  bool get successful;
}