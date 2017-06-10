enum JoinType { INNER, LEFT, RIGHT, FULL }

String joinTypeToString(JoinType type) {
  switch (type) {
    case JoinType.INNER:
      return 'INNER';
    case JoinType.LEFT:
      return 'LEFT';
    case JoinType.RIGHT:
      return 'RIGHT';
    case JoinType.FULL:
      return 'FULL OUTER';
  }

  throw new ArgumentError('Invalid join type: $type');
}
