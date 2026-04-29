import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_repository_impl.dart';

class BrandDropdown extends StatefulWidget {
  final String? selectedBrandId;
  final Function(String?) onBrandChanged;

  const BrandDropdown({
    super.key,
    required this.selectedBrandId,
    required this.onBrandChanged,
  });

  @override
  State<BrandDropdown> createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  // final ProductMetadataDatasource _dataSource = ProductMetadataDatasource();
  final ProductMetadataRepositoryImpl _repository = ProductMetadataRepositoryImpl.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _repository.getBrands(page: 1, pageSize: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: null,
                decoration: InputDecoration(
                  labelText: ProductStrings.brand,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                  errorText: 'Failed to load brands',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                ],
                onChanged: null,
              ),
              SizedBox(height: 8),
              Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          );
        }

        final response = snapshot.data;
        final brands = response?.brands ?? [];

        return DropdownButtonFormField<String?>(
          initialValue: widget.selectedBrandId,
          decoration: InputDecoration(
            labelText: ProductStrings.brandRequired,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None'),
            ),
            ...brands.map((brand) {
              return DropdownMenuItem(
                value: brand.id,
                child: Text(brand.name),
              );
            }),
          ],
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
