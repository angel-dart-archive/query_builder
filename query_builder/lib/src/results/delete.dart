class DeletionResult<T> {
  final List<String> _errors = [];
  final List<String> _deletedIds = [];
  final List<T> _deletedItems = [];

  final int numberDeleted;
  final bool successful;
  final String message;

  List<String> get errors => new List<String>.unmodifiable(_errors);

  List<String> get deletedIds => new List<String>.unmodifiable(_deletedIds);

  List<T> get deletedItems => new List<T>.unmodifiable(_deletedItems);

  DeletionResult(this.numberDeleted, this.successful,
      {Iterable<String> deletedIds: const [],
      Iterable<T> deletedItems: const [],
      Iterable<String> errors: const [],
      this.message}) {
    _errors.addAll(errors ?? []);
    _deletedIds.addAll(deletedIds ?? []);
    _deletedItems.addAll(deletedItems ?? []);
  }
}
