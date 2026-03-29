import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.headingText, this.linkText, this.linkDestination, this.filterArguments});

  final String headingText;
  final String? linkText;
  final String? linkDestination;
  final FilterArguments? filterArguments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headingText,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Divider(
            color: Colors.grey[350],
            thickness: 2.0,
            height: 5.0,
          ),
          if (linkText != null && linkDestination != null)
            TextButton(
              onPressed: () {
                log("ok");
                Navigator.of(context).pushNamed(linkDestination!, arguments: filterArguments);
              },
              child: Text(linkText!),
            )
        ],
      ),
    );
  }

}