int resolveBrandPageAfterDelete({
  required int currentPage,
  required int pageSize,
  required int totalItems,
  required bool includeInactive,
  int deletedItemsCount = 1,
}) {
  // When including inactive items, soft-deleted items remain visible,
  // so the current page is still valid
  if (includeInactive) {
    return currentPage;
  }

  // When filtering out inactive items, the deleted item is removed from results
  final adjustedTotalItems = (totalItems - deletedItemsCount).clamp(0, totalItems);
  final adjustedTotalPages = adjustedTotalItems == 0
      ? 0
      : ((adjustedTotalItems + pageSize - 1) ~/ pageSize);
  final maxPage = adjustedTotalPages == 0 ? 1 : adjustedTotalPages;
  return currentPage > maxPage ? maxPage : currentPage;
}
