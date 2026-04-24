import 'package:flutter/material.dart';

class ProductPickerSearchBar extends StatelessWidget {
  const ProductPickerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, _, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search by name, SKU, barcode, brand or category',
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_outlined),
                    onPressed: onClear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
