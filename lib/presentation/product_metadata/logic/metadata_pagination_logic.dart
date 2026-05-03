int resolveMetadataPageAfterDelete({
  required int currentPage,
  required int pageSize,
  required int totalItems,
  int deletedItemsCount = 1,
}) {
  final adjustedTotalItems = (totalItems - deletedItemsCount).clamp(0, totalItems);

  if (adjustedTotalItems == 0) {
    return 1;
  }

  final adjustedTotalPages = (adjustedTotalItems + pageSize - 1) ~/ pageSize;
  final maxPage = adjustedTotalPages == 0 ? 1 : adjustedTotalPages;

  return currentPage > maxPage ? maxPage : currentPage;
}
