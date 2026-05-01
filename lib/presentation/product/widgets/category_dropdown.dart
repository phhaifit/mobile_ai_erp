import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class CategoryDropdown extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategoryChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final ProductMetadataDatasource _dataSource = ProductMetadataDatasource();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataSource.getCategories(),
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
                  labelText: ProductStrings.categoryRequired,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  errorText: 'Failed to load categories',
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
        final categories = response?.categories ?? [];


        return DropdownButtonFormField<String?>(
          initialValue: widget.selectedCategoryId,
          decoration: InputDecoration(
            labelText: ProductStrings.categoryRequired,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }),
          ],
          onChanged: (categoryId) {
            if (categoryId != null) {
              widget.onCategoryChanged(categoryId);
            }
          },
        );
      },
    );
  }
}
