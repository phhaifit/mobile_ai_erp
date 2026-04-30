import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_secondary_details.dart';
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (detailLines.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          MetadataSecondaryDetails(lines: detailLines),
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
              if (chips.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (
                            var index = 0;
                            index < chips.length;
                            index++
                          ) ...[
                            chips[index],
                            if (index < chips.length - 1)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
