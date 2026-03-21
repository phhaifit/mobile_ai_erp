import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_color_utils.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductMetadataTagFormScreen extends StatefulWidget {
  const ProductMetadataTagFormScreen({
    super.key,
    this.args,
  });

  final TagFormArgs? args;

  @override
  State<ProductMetadataTagFormScreen> createState() =>
      _ProductMetadataTagFormScreenState();
}

class _ProductMetadataTagFormScreenState
    extends State<ProductMetadataTagFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorHexController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  Tag? _editingTag;
  TagStatus _status = TagStatus.active;
  bool _isSaving = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    _colorHexController.addListener(_handleColorHexChanged);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    _editingTag = _store.findTagById(widget.args?.tagId);
    if (_editingTag != null) {
      _nameController.text = _editingTag!.name;
      _descriptionController.text = _editingTag!.description ?? '';
      _colorHexController.text = _editingTag!.colorHex ?? '';
      _sortOrderController.text = _editingTag!.sortOrder.toString();
      _status = _editingTag!.status;
    } else {
      _sortOrderController.text = '0';
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _colorHexController.removeListener(_handleColorHexChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _colorHexController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = tryParseHexColor(_colorHexController.text);
    final previewBackground = selectedColor == null
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : softenedColor(selectedColor, amount: 0.62);
    final previewForeground = selectedColor == null
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : readableForegroundFor(previewBackground);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTag == null ? 'New tag' : 'Edit tag'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: metadataFormDecoration(
                  labelText: 'Name',
                  errorText: _nameErrorText,
                ),
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
                decoration: metadataFormDecoration(
                  labelText: 'Description',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorHexController,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: previewForeground,
                      fontWeight: FontWeight.w600,
                    ),
                decoration: metadataFormDecoration(
                  labelText: 'Color',
                  hintText: '#FF6B6B',
                ).copyWith(
                  filled: true,
                  fillColor: previewBackground,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selectedColor ??
                            Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const SizedBox(width: 20, height: 20),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 96,
                    minHeight: 48,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        onPressed: _pickColor,
                        icon: const Icon(Icons.palette_outlined),
                        tooltip: 'Pick color',
                      ),
                      if (_colorHexController.text.trim().isNotEmpty)
                        IconButton(
                          onPressed: _clearColor,
                          icon: const Icon(Icons.close),
                          tooltip: 'Clear color',
                        ),
                    ],
                  ),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return null;
                  }
                  if (tryParseHexColor(trimmed) == null) {
                    return 'Enter a valid 6-digit hex color.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TagStatus>(
                initialValue: _status,
                decoration: metadataFormDecoration(
                  labelText: 'Status',
                ),
                items: TagStatus.values
                    .map(
                      (status) => DropdownMenuItem<TagStatus>(
                        value: status,
                        child: MetadataStatusChip(label: status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: metadataFormDecoration(
                  labelText: 'Sort order',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sort order is required.';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Sort order must be a number.';
                  }
                  return null;
                },
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
                label:
                    Text(_editingTag == null ? 'Create tag' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _nameErrorText = null;
    });

    try {
      await _store.saveTag(
        Tag(
          id: _editingTag?.id ?? '',
          name: _nameController.text.trim(),
          description: _trimOrNull(_descriptionController.text),
          colorHex: _normalizedColorHex(),
          sortOrder: int.parse(_sortOrderController.text.trim()),
          status: _status,
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on ProductMetadataValidationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _nameErrorText = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save tag. Try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizedColorHex() {
    final parsedColor = tryParseHexColor(_colorHexController.text);
    if (parsedColor == null) {
      return null;
    }
    return formatHexColor(parsedColor);
  }

  void _clearNameError() {
    if (_nameErrorText == null) {
      return;
    }
    setState(() {
      _nameErrorText = null;
    });
  }

  void _handleColorHexChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickColor() async {
    final selected = await showModalBottomSheet<Color>(
      context: context,
      builder: (context) {
        return _TagColorPaletteSheet(
          initialColor: tryParseHexColor(_colorHexController.text),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    _colorHexController.text = formatHexColor(selected);
  }

  void _clearColor() {
    _colorHexController.clear();
  }
}

class _TagColorPaletteSheet extends StatelessWidget {
  const _TagColorPaletteSheet({
    required this.initialColor,
  });

  final Color? initialColor;

  static const List<Color> _palette = <Color>[
    Color(0xFFE57373),
    Color(0xFFFF8A65),
    Color(0xFFFFB74D),
    Color(0xFFFFD54F),
    Color(0xFFAED581),
    Color(0xFF81C784),
    Color(0xFF4DB6AC),
    Color(0xFF4FC3F7),
    Color(0xFF64B5F6),
    Color(0xFF7986CB),
    Color(0xFFBA68C8),
    Color(0xFFF06292),
    Color(0xFFA1887F),
    Color(0xFF90A4AE),
    Color(0xFF37474F),
    Color(0xFF212121),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pick a color',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a preset swatch, then adjust the hex value manually if needed.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _palette.map((color) {
                final isSelected = initialColor?.toARGB32() == color.toARGB32();
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(context).pop(color),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: readableForegroundFor(color),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
