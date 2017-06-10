enum UnionType { NORMAL, ALL }

String unionTypeToString(UnionType type) {
  switch (type) {
    case UnionType.NORMAL:
      return 'UNION';
    case UnionType.ALL:
      return 'UNION ALL';
    default:
      throw new ArgumentError('Invalid union type $type');
  }
}
