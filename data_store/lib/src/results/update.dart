class UpdateResult<T> {
  final List<String> _updatedIds = [];
  final List<T> _updatedItems = [];

  final int numberUpdated;
  final bool successful;

  List<String> get updatedIds => new List<String>.unmodifiable(_updatedIds);

  List<String> get updatedItems => new List<String>.unmodifiable(_updatedItems);

  UpdateResult(this.numberUpdated, this.successful,
      {Iterable<String> updatedIds: const [],
      Iterable<T> updatedItems: const []}) {
    _updatedIds.addAll(updatedIds ?? []);
    _updatedItems.addAll(updatedItems ?? []);
  }
}
