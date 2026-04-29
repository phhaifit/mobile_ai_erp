import 'dart:math';

class PaginationMeta {
  final int _page;
  final int _pageSize;
  final int _totalItems;
  final int _totalPages;

  PaginationMeta()
    : _page = 1,
      _pageSize = 20,
      _totalItems = 0,
      _totalPages = 0;

  PaginationMeta.fromJson(Map<String, dynamic> json)
    : _page = json['page'] ?? 1,
      _pageSize = json['pageSize'] ?? 20,
      _totalItems = json['totalItems'] ?? 0,
      _totalPages = json['totalPages'] ?? 0;

  int get page => _page;
  int get pageSize => _pageSize;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;

  int get nextPage => _page < _totalPages ? _page + 1 : -1;
  int get firstIndex => (_page - 1) * _pageSize + 1;
  int get lastIndex => min(_page * _pageSize, _totalItems);
  bool get isLastPage => _page >= _totalPages;
}
