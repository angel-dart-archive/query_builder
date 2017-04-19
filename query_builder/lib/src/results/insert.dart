class InsertionResult<T> {
  final List<String> _errors = [];
  final List<String> _insertedIds = [];
  final List<T> _insertedItems = [];

  final int numberInserted;
  final bool successful;
  final String message;

  List<String> get errors => new List<String>.unmodifiable(_errors);

  List<String> get insertedIds => new List<String>.unmodifiable(_insertedIds);

  List<T> get insertedItems => new List<T>.unmodifiable(_insertedItems);

  InsertionResult(this.numberInserted, this.successful,
      {Iterable<String> createdIds: const [],
      Iterable<T> createdItems: const [],
      Iterable<String> errors: const [],
      this.message}) {
    _errors.addAll(errors ?? []);
    _insertedIds.addAll(createdIds ?? []);
    _insertedItems.addAll(createdItems ?? []);
  }
}
