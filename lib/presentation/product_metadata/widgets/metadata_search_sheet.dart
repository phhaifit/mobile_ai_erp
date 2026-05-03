import 'package:flutter/material.dart';

class MetadataSearchSheet extends StatelessWidget {
  const MetadataSearchSheet({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;

  static Future<void> show(
    BuildContext context, {
    required TextEditingController searchController,
    required String searchHint,
    required ValueChanged<String> onSearchChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MetadataSearchSheet(
        searchController: searchController,
        searchHint: searchHint,
        onSearchChanged: onSearchChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Search', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          MetadataSearchField(
            searchController: searchController,
            searchHint: searchHint,
            showHelperText: true,
            onSearchChanged: onSearchChanged,
            onClear: () {
              searchController.clear();
              onSearchChanged('');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class MetadataSearchField extends StatelessWidget {
  const MetadataSearchField({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.showHelperText,
    required this.onSearchChanged,
    this.onClear,
  });

  final TextEditingController searchController;
  final String searchHint;
  final bool showHelperText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: searchController,
      builder: (context, _, _) => TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: showHelperText ? 'Search' : searchHint,
          hintMaxLines: 2,
          helperText: showHelperText ? searchHint : null,
          helperMaxLines: 3,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear ??
                      () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                ),
        ),
      ),
    );
  }
}
