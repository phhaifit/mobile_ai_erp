class PaginatedResult<T> {
  final List<T> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginatedResult({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
}
