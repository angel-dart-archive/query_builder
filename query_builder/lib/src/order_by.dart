enum OrderBy { ASCENDING, DESCENDING, RANDOM }

String orderByToString(OrderBy orderBy) {
  switch (orderBy) {
    case OrderBy.ASCENDING:
      return 'ASC';
    case OrderBy.DESCENDING:
      return 'DESC';
    case OrderBy.RANDOM:
      return 'RAND()';
    default:
      throw new ArgumentError('Invalid order by type: $orderBy');
  }
}
