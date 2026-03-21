import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class CategoryDropdown extends StatefulWidget {
  final int selectedCategoryId;
  final Function(int) onCategoryChanged;

  const CategoryDropdown({
    Key? key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final MockProductDataSource _dataSource = MockProductDataSource();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataSource.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        final categories = snapshot.data ?? [];

        return DropdownButtonFormField<int>(
          value: widget.selectedCategoryId,
          decoration: InputDecoration(
            labelText: ProductStrings.categoryRequired,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
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
