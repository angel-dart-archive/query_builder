class InsertionResult<T> {
  final List<String> _insertedIds = [];
  final List<T> _insertedItems = [];

  final int numberInserted;
  final bool successful;

  List<String> get insertedIds => new List<String>.unmodifiable(_insertedIds);

  List<String> get insertedItems => new List<String>.unmodifiable(_insertedItems);

  InsertionResult(this.numberInserted, this.successful,
      {Iterable<String> createdIds: const [],
      Iterable<T> createdItems: const []}) {
    _insertedIds.addAll(createdIds ?? []);
    _insertedItems.addAll(createdItems ?? []);
  }
}
