import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

ReactionDisposer createMetadataErrorReaction({
  required BuildContext context,
  required String Function() errorMessage,
  required bool Function() isMounted,
  required String actionLabel,
}) {
  return reaction((_) => errorMessage(), (String msg) {
    if (msg.isEmpty || !isMounted() || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(MetadataErrorFormatter.formatActionError(
          error: msg,
          actionLabel: actionLabel,
        )),
      ));
  });
}
