enum JoinType { INNER, LEFT, RIGHT, FULL_OUTER }

String joinTypeToString(JoinType type) {
  switch (type) {
    case JoinType.INNER:
      return 'INNER';
    case JoinType.LEFT:
      return 'LEFT';
    case JoinType.RIGHT:
      return 'RIGHT';
    case JoinType.FULL_OUTER:
      return 'FULL OUTER';
  }

  throw new ArgumentError('Invalid join type: $type');
}
