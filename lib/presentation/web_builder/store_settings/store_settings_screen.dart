import 'package:flutter/material.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Mock data pre-filled in controllers
  late final TextEditingController _storeNameController;
  late final TextEditingController _taglineController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: 'Jarvis Store');
    _taglineController = TextEditingController(text: 'Smart Shopping, Simplified');
    _emailController = TextEditingController(text: 'contact@jarvisstore.com');
    _phoneController = TextEditingController(text: '+84 123 456 789');
    _addressController =
        TextEditingController(text: '227 Nguyen Van Cu, District 5, HCMC');
    _currencyController = TextEditingController(text: 'VND');
    _descriptionController = TextEditingController(
      text:
          'Your one-stop shop for electronics, accessories, and smart home devices.',
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _taglineController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Logo section
              _buildLogoSection(theme),
              const SizedBox(height: 28),

              // General Info
              _buildSectionTitle(theme, 'General Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _storeNameController,
                label: 'Store Name',
                icon: Icons.store_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Store name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _taglineController,
                label: 'Tagline',
                icon: Icons.format_quote_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // Contact Info
              _buildSectionTitle(theme, 'Contact Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              // Business Settings
              _buildSectionTitle(theme, 'Business Settings'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _currencyController,
                label: 'Currency',
                icon: Icons.attach_money_outlined,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          // Logo placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logo upload will be available in Phase 2'),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Change Logo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulate network delay (mock)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store settings saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
