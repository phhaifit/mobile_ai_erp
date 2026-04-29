import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';

class CategoryParentDropdown extends StatelessWidget {
  const CategoryParentDropdown({
    super.key,
    required this.categories,
    required this.selectedParentId,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? selectedParentId;
  final ValueChanged<String?> onChanged;

  String _label(Category category) {
    final path = <String>[category.name];
    Category? current = category;
    while (current?.parentId != null) {
      final parent = categories.where((c) => c.id == current!.parentId).firstOrNull;
      if (parent == null) break;
      path.insert(0, parent.name);
      current = parent;
    }
    return path.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final currentParentInList = categories.any((c) => c.id == selectedParentId);

    return DropdownButtonFormField<String?>(
      isExpanded: true,
      initialValue: selectedParentId,
      decoration: metadataFormDecoration(labelText: 'Parent'),
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(
          value: null,
          child: _Label('No parent (top-level category)'),
        ),
        ...categories.map(
          (c) => DropdownMenuItem<String?>(value: c.id, child: _Label(_label(c))),
        ),
        if (selectedParentId != null && !currentParentInList)
          DropdownMenuItem<String?>(
            value: selectedParentId,
            child: const _Label('Current parent'),
          ),
      ],
      selectedItemBuilder: (context) => <Widget>[
        const _Label('No parent (top-level category)'),
        ...categories.map((c) => _Label(_label(c))),
        if (selectedParentId != null && !currentParentInList) const _Label('Current parent'),
      ],
      onChanged: onChanged,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: double.infinity,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    ),
  );
}
