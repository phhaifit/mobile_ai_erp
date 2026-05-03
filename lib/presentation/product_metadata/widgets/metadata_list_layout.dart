import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_loading_overlay.dart';

class MetadataListLayout extends StatelessWidget {
  const MetadataListLayout({
    super.key,
    required this.isLoading,
    required this.controls,
    required this.child,
  });

  final bool isLoading;
  final Widget controls;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: controls,
        ),
        Expanded(
          child: MetadataLoadingOverlay(
            isLoading: isLoading,
            child: child,
          ),
        ),
      ],
    );
  }
}
