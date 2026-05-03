import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';

class MetadataListScaffold extends StatelessWidget {
  const MetadataListScaffold({
    super.key,
    required this.title,
    required this.addLabel,
    required this.isLoading,
    required this.controls,
    required this.child,
    required this.onAdd,
  });

  final String title;
  final String addLabel;
  final bool isLoading;
  final Widget controls;
  final Widget child;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).popUntil(
              (r) =>
                  r.settings.name == ProductMetadataNavigator.productMetadataHomeRoute ||
                  r.isFirst,
            ),
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(addLabel),
      ),
      body: MetadataListLayout(
        isLoading: isLoading,
        controls: controls,
        child: child,
      ),
    );
  }
}
