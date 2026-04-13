import 'package:flutter/material.dart';

class MetadataLoadingOverlay extends StatelessWidget {
  const MetadataLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: isLoading,
          child: Opacity(opacity: isLoading ? 0.5 : 1.0, child: child),
        ),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
