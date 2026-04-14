/// Logic for resolving the correct page number after a metadata item is deleted or deactivated.
///
/// This handles the edge case where the last item on the last page is removed,
/// ensuring the UI doesn't "hang" on an empty page.
int resolveMetadataPageAfterDelete({
  required int currentPage,
  required int pageSize,
  required int totalItems,
  bool includeInactive = false,
  int deletedItemsCount = 1,
}) {
  // When including inactive items, soft-deleted items remain visible in the list,
  // so the count and results don't change from the UI's perspective.
  if (includeInactive) {
    return currentPage;
  }

  // When filtering out inactive items (or for hard-deleted items),
  // the item is removed from the matching results.
  final adjustedTotalItems = (totalItems - deletedItemsCount).clamp(0, totalItems);
  
  if (adjustedTotalItems == 0) {
    return 1;
  }

  final adjustedTotalPages = (adjustedTotalItems + pageSize - 1) ~/ pageSize;
  final maxPage = adjustedTotalPages == 0 ? 1 : adjustedTotalPages;

  return currentPage > maxPage ? maxPage : currentPage;
}
