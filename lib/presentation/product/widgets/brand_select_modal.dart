import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/paginated_selection_modal.dart';

class BrandSelectModal extends StatelessWidget {
  final String? initialBrandId;
  final String? initialBrandName;
  final ValueChanged<String?> onBrandSelected;

  const BrandSelectModal({
    super.key,
    required this.initialBrandId,
    required this.initialBrandName,
    required this.onBrandSelected,
  });

  Future<(List<Brand>, int)> _fetchBrands(int page, int pageSize) async {
    final repository = getIt<ProductMetadataRepository>();
    final response = await repository.getBrands(
      page: page,
      pageSize: pageSize,
    );
    return (response.brands, response.meta.totalPages);
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedSelectionModal<Brand>(
      initialSelectionId: initialBrandId,
      initialSelectionName: initialBrandName,
      title: ProductStrings.selectBrandTitle,
      selectedLabel: ProductStrings.selectedBrandLabel,
      noItemsMessage: ProductStrings.noBrandsMessage,
      noSelectionText: ProductStrings.noBrandSelectedText,
      fetchItems: _fetchBrands,
      getItemId: (brand) => brand.id,
      getItemName: (brand) => brand.name,
      onSelectionChanged: onBrandSelected,
    );
  }
}
