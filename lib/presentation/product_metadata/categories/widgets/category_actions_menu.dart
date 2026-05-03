import 'package:flutter/material.dart';

enum CategoryMenuAction { addChild, edit, delete }

class CategoryActionsMenu extends StatelessWidget {
  const CategoryActionsMenu({super.key, required this.onSelected});

  final ValueChanged<CategoryMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CategoryMenuAction>(
      tooltip: 'Category actions',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      iconSize: 20,
      onSelected: onSelected,
      itemBuilder: (context) => const <PopupMenuEntry<CategoryMenuAction>>[
        PopupMenuItem<CategoryMenuAction>(
          value: CategoryMenuAction.addChild,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.add_circle_outline),
            title: Text('Add subcategory'),
          ),
        ),
        PopupMenuItem<CategoryMenuAction>(
          value: CategoryMenuAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<CategoryMenuAction>(
          value: CategoryMenuAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
