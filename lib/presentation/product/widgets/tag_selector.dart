import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tags_usecase.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTagIds;
  final Function(String) onTagToggled;

  const TagSelector({
    Key? key,
    required this.selectedTagIds,
    required this.onTagToggled,
  }) : super(key: key);

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final GetTagsUseCase _getTagsUseCase = getIt<GetTagsUseCase>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getTagsUseCase.call(params: GetTagsParams(page: 1, pageSize: 100)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        final response = snapshot.data;
        final tags = response?.items ?? [];

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
