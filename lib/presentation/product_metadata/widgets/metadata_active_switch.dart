import 'package:flutter/material.dart';

class MetadataActiveSwitch extends StatelessWidget {
  const MetadataActiveSwitch({
    super.key,
    required this.value,
    required this.resourceLabel,
    required this.onChanged,
  });

  final bool value;
  final String resourceLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.35,
        );

    return SwitchListTile.adaptive(
      value: value,
      contentPadding: EdgeInsets.zero,
      title: const Text('Active'),
      subtitle: Text(
        'Turn this off to stop using this $resourceLabel for new products. You can still find it later with Include inactive.',
        style: subtitleStyle,
      ),
      onChanged: onChanged,
    );
  }
}
