import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_form_decoration.dart';
import 'package:flutter/material.dart';

const List<String> _kPresetColors = <String>[
  '#6A1B9A',
  '#1565C0',
  '#2E7D32',
  '#C62828',
  '#EF6C00',
  '#37474F',
  '#00838F',
  '#AD1457',
];

class CustomerGroupFormScreen extends StatefulWidget {
  const CustomerGroupFormScreen({super.key, this.args});

  final CustomerGroupFormArgs? args;

  @override
  State<CustomerGroupFormScreen> createState() =>
      _CustomerGroupFormScreenState();
}

class _CustomerGroupFormScreenState extends State<CustomerGroupFormScreen> {
  final CustomerStore _store = getIt<CustomerStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  CustomerGroupStatus _status = CustomerGroupStatus.active;
  String? _selectedColor;
  bool _isSaving = false;
  CustomerGroup? _editingGroup;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    _editingGroup = _store.findGroupById(widget.args?.groupId);

    if (_editingGroup != null) {
      _nameController.text = _editingGroup!.name;
      _descriptionController.text = _editingGroup!.description ?? '';
      _sortOrderController.text = _editingGroup!.sortOrder.toString();
      _status = _editingGroup!.status;
      _selectedColor = _editingGroup!.colorHex;
    } else {
      _sortOrderController.text = '0';
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_editingGroup == null ? 'New group' : 'Edit group'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: customerFormDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: customerFormDecoration(
                    labelText: 'Description (optional)'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CustomerGroupStatus>(
                initialValue: _status,
                decoration: customerFormDecoration(labelText: 'Status'),
                items: CustomerGroupStatus.values
                    .map(
                      (s) => DropdownMenuItem<CustomerGroupStatus>(
                        value: s,
                        child: Text(s.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: customerFormDecoration(labelText: 'Sort order'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sort order is required.';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Must be a number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _ColorPicker(
                selectedColor: _selectedColor,
                presetColors: _kPresetColors,
                onSelected: (color) =>
                    setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                    _editingGroup == null ? 'Create group' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _store.saveCustomerGroup(
        CustomerGroup(
          id: _editingGroup?.id ?? '',
          name: _nameController.text.trim(),
          description: _trimOrNull(_descriptionController.text),
          colorHex: _selectedColor,
          sortOrder: int.parse(_sortOrderController.text.trim()),
          status: _status,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on CustomerValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Couldn\'t save group. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.presetColors,
    required this.onSelected,
    this.selectedColor,
  });

  final List<String> presetColors;
  final String? selectedColor;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        // "No color" option
        GestureDetector(
          onTap: () => onSelected(null),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: selectedColor == null ? 3 : 1,
              ),
            ),
            child: const Icon(Icons.block, size: 18),
          ),
        ),
        for (final hex in presetColors)
          GestureDetector(
            onTap: () => onSelected(hex),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _hexToColor(context, hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == hex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: selectedColor == hex
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }

  Color _hexToColor(BuildContext context, String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
