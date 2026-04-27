class MetadataListQuery {
  const MetadataListQuery({
    this.search = '',
    this.page = 1,
    this.pageSize = 10,
    this.sortBy,
    this.sortOrder,
  });

  final String search;
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder;

  bool get hasCustomSort =>
      (sortBy?.trim().isNotEmpty ?? false) ||
      (sortOrder?.trim().isNotEmpty ?? false);

  MetadataListQuery copyWith({
    String? search,
    int? page,
    int? pageSize,
    Object? sortBy = _sentinel,
    Object? sortOrder = _sentinel,
  }) {
    return MetadataListQuery(
      search: search ?? this.search,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: identical(sortBy, _sentinel) ? this.sortBy : sortBy as String?,
      sortOrder: identical(sortOrder, _sentinel)
          ? this.sortOrder
          : sortOrder as String?,
    );
  }
}

const Object _sentinel = Object();
