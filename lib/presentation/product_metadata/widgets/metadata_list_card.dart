import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_secondary_details.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';

class MetadataListCard extends StatelessWidget {
  const MetadataListCard({
    super.key,
    required this.title,
    required this.leading,
    this.detailLines = const <String>[],
    this.chips = const <Widget>[],
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget leading;
  final List<String> detailLines;
  final List<Widget> chips;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: leading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (detailLines.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      MetadataSecondaryDetails(lines: detailLines),
                    ],
                    if (chips.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chips,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MetadataBooleanChip extends StatelessWidget {
  const MetadataBooleanChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return MetadataStatusChip(label: label);
  }
}
