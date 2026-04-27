import 'package:flutter/material.dart';

class AttributeValueField {
  AttributeValueField({this.id = '', required String initialText, int sortOrder = 0})
      : controller = TextEditingController(text: initialText),
        sortOrderController = TextEditingController(text: sortOrder.toString());

  final String id;
  final TextEditingController controller;
  final TextEditingController sortOrderController;

  void dispose() {
    controller.dispose();
    sortOrderController.dispose();
  }
}

class AttributeValuesEditor extends StatelessWidget {
  const AttributeValuesEditor({
    super.key,
    required this.fields,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  final List<AttributeValueField> fields;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Values', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add value'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (fields.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No values added yet.'),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fields.length,
            onReorder: onReorder,
            itemBuilder: (context, index) => _ValueRow(
              key: ValueKey(fields[index]),
              field: fields[index],
              index: index,
              allFields: fields,
              onRemove: () => onRemove(index),
            ),
          ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    super.key,
    required this.field,
    required this.index,
    required this.allFields,
    required this.onRemove,
  });

  final AttributeValueField field;
  final int index;
  final List<AttributeValueField> allFields;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ReorderableDragStartListener(
              index: index,
              child: const MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Icon(Icons.drag_indicator, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: field.controller,
              decoration: const InputDecoration(
                labelText: 'Value', hintText: 'e.g. Red',
                border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              validator: (val) {
                final t = val?.trim() ?? '';
                if (t.isEmpty) return 'Required';
                if (t.length > 100) return 'Max 100 characters.';
                final lower = t.toLowerCase();
                final count = allFields.where((f) => f.controller.text.trim().toLowerCase() == lower && f.controller.text.trim().isNotEmpty).length;
                if (count > 1) return 'Duplicate value.';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: field.sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Sort', border: OutlineInputBorder(), isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                if (int.tryParse(val.trim()) == null) return 'Must be a number';
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: Colors.red,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
