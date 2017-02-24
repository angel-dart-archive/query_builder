class DeletionResult<T> {
  final List<String> _deletedIds = [];
  final List<T> _deletedItems = [];

  final int numberDeleted;
  final bool successful;

  List<String> get deletedIds => new List<String>.unmodifiable(_deletedIds);

  List<String> get deletedItems => new List<String>.unmodifiable(_deletedItems);

  DeletionResult(this.numberDeleted, this.successful,
      {Iterable<String> deletedIds: const [],
      Iterable<T> deletedItems: const []}) {
    _deletedIds.addAll(deletedIds ?? []);
    _deletedItems.addAll(deletedItems ?? []);
  }
}
