import 'package:flutter/material.dart';

enum CategoryViewMode { list, tree }

extension CategoryViewModeUi on CategoryViewMode {
  IconData get switchIcon =>
      this == CategoryViewMode.list ? Icons.device_hub_outlined : Icons.view_list_outlined;

  String get switchTooltip =>
      this == CategoryViewMode.list ? 'Tree view' : 'List view';

  CategoryViewMode get toggled =>
      this == CategoryViewMode.list ? CategoryViewMode.tree : CategoryViewMode.list;
}
