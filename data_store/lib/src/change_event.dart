class ChangeEvent<T> {
  final ChangeEventType type;
  final T oldValue, newValue;

  ChangeEvent(this.type, this.oldValue, this.newValue);
}

enum ChangeEventType { CREATED, UPDATED, REMOVED }
