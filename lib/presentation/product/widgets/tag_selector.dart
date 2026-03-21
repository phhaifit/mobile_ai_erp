import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class TagSelector extends StatefulWidget {
  final List<int> selectedTagIds;
  final Function(int) onTagToggled;

  const TagSelector({
    Key? key,
    required this.selectedTagIds,
    required this.onTagToggled,
  }) : super(key: key);

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final MockProductDataSource _dataSource = MockProductDataSource();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataSource.getTags(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        final tags = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProductStrings.tags,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isSelected = widget.selectedTagIds.contains(tag.id);
                return FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    widget.onTagToggled(tag.id);
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
