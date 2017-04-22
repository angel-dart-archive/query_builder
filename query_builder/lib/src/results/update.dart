class UpdateResult<T> {
  final List<String> _errors = [];
  final List<String> _updatedIds = [];
  final List<T> _updatedItems = [];

  final int numberUpdated;
  final bool successful;
  final String message;
  final StackTrace stackTrace;

  List<String> get errors => new List<String>.unmodifiable(_errors);

  List<String> get updatedIds => new List<String>.unmodifiable(_updatedIds);

  List<T> get updatedItems => new List<T>.unmodifiable(_updatedItems);

  UpdateResult(this.numberUpdated, this.successful,
      {Iterable<String> updatedIds: const [],
      Iterable<T> updatedItems: const [],
      Iterable<String> errors: const [],
      this.message,
      this.stackTrace}) {
    _errors.addAll(errors ?? []);
    _updatedIds.addAll(updatedIds ?? []);
    _updatedItems.addAll(updatedItems ?? []);
  }
}
