import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class BrandDropdown extends StatefulWidget {
  final int selectedBrandId;
  final Function(int) onBrandChanged;

  const BrandDropdown({
    super.key,
    required this.selectedBrandId,
    required this.onBrandChanged,
  });

  @override
  State<BrandDropdown> createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  final MockProductDataSource _dataSource = MockProductDataSource();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataSource.getBrands(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        final brands = snapshot.data ?? [];

        return DropdownButtonFormField<int>(
          initialValue: widget.selectedBrandId,
          decoration: InputDecoration(
            labelText: ProductStrings.brandRequired,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          items: brands.map((brand) {
            return DropdownMenuItem(
              value: brand.id,
              child: Text(brand.name),
            );
          }).toList(),
          onChanged: (brandId) {
            if (brandId != null) {
              widget.onBrandChanged(brandId);
            }
          },
        );
      },
    );
  }
}
