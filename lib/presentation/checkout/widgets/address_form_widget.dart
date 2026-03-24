import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';

/// A form widget for entering/editing delivery address with AI parsing support
class AddressFormWidget extends StatefulWidget {
  const AddressFormWidget({
    super.key,
    this.initialAddress,
    required this.onSave,
    this.onParseAddress,
    this.isSaving = false,
    this.isParsing = false,
    this.showAiParsing = true,
  });

  final DeliveryAddress? initialAddress;
  final ValueChanged<DeliveryAddress> onSave;
  final Future<DeliveryAddress?> Function(String rawAddress)? onParseAddress;
  final bool isSaving;
  final bool isParsing;
  final bool showAiParsing;

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _rawAddressController = TextEditingController();

  bool _isDefault = false;
  bool _showAiParseField = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _fullNameController.text = widget.initialAddress!.fullName;
      _phoneController.text = widget.initialAddress!.phone ?? '';
      _streetController.text = widget.initialAddress!.street;
      _cityController.text = widget.initialAddress!.city;
      _stateController.text = widget.initialAddress!.state ?? '';
      _postalCodeController.text = widget.initialAddress!.postalCode ?? '';
      _countryController.text = widget.initialAddress!.country ?? '';
      _isDefault = widget.initialAddress!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _rawAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleParseAddress() async {
    if (widget.onParseAddress == null) return;
    if (_rawAddressController.text.trim().isEmpty) return;

    final parsed = await widget.onParseAddress!(_rawAddressController.text.trim());
    if (parsed != null && mounted) {
      setState(() {
        _fullNameController.text = parsed.fullName;
        _phoneController.text = parsed.phone ?? '';
        _streetController.text = parsed.street;
        _cityController.text = parsed.city;
        _stateController.text = parsed.state ?? '';
        _postalCodeController.text = parsed.postalCode ?? '';
        _countryController.text = parsed.country ?? '';
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final address = DeliveryAddress(
      id: widget.initialAddress?.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
      countryCode: widget.initialAddress?.countryCode ?? 'US',
      isDefault: _isDefault,
    );

    widget.onSave(address);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI Smart Address Parsing
          if (widget.showAiParsing) ...[
            _buildAiParseSection(context),
            const Divider(height: 32),
          ],

          // Manual Address Form
          _buildTextFormField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'John Doe',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+1 234 567 8900',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _streetController,
            label: 'Street Address',
            hint: '123 Main Street',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Street address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextFormField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'New York',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'NY',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  hint: '10001',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFormField(
                  controller: _countryController,
                  label: 'Country',
                  hint: 'United States',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Default Address Toggle
          SwitchListTile(
            title: const Text('Set as default address'),
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Save Button
          FilledButton(
            onPressed: widget.isSaving ? null : _handleSave,
            child: widget.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildAiParseSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showAiParseField = !_showAiParseField),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Address Parsing',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Icon(
                _showAiParseField
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
        if (_showAiParseField) ...[
          const SizedBox(height: 12),
          Text(
            'Paste your full address and we\'ll automatically parse it into the form fields.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rawAddressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Paste your address here...\nExample: John Doe, 123 Main St, New York, NY 10001, USA',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: widget.isParsing ? null : _handleParseAddress,
              icon: widget.isParsing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high),
              label: Text(widget.isParsing ? 'Parsing...' : 'Parse Address'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }
}
