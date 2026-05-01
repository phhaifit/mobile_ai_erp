import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/paginated_selection_modal.dart';

class CategorySelectModal extends StatelessWidget {
  final String? initialCategoryId;
  final String? initialCategoryName;
  final ValueChanged<String?> onCategorySelected;

  const CategorySelectModal({
    super.key,
    required this.initialCategoryId,
    required this.initialCategoryName,
    required this.onCategorySelected,
  });

  Future<(List<Category>, int)> _fetchCategories(int page, int pageSize) async {
    final repository = getIt<ProductMetadataRepository>();
    final response = await repository.getCategories(
      page: page,
      pageSize: pageSize,
    );
    return (response.categories, response.meta.totalPages);
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedSelectionModal<Category>(
      initialSelectionId: initialCategoryId,
      initialSelectionName: initialCategoryName,
      title: ProductStrings.selectCategoryTitle,
      selectedLabel: ProductStrings.selectedCategoryLabel,
      noItemsMessage: ProductStrings.noCategoriesMessage,
      noSelectionText: ProductStrings.noCategorySelectedText,
      fetchItems: _fetchCategories,
      getItemId: (category) => category.id,
      getItemName: (category) => category.name,
      onSelectionChanged: onCategorySelected,
    );
  }
}
