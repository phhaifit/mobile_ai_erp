import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/presentation/customer/store/subdomain_store.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';

/// Screen for customers to input their subdomain
class SubdomainScreen extends StatefulWidget {
  const SubdomainScreen({super.key});

  @override
  State<SubdomainScreen> createState() => _SubdomainScreenState();
}

class _SubdomainScreenState extends State<SubdomainScreen> {
  late TextEditingController _subdomainController;
  late SubdomainStore _subdomainStore;

  @override
  void initState() {
    super.initState();
    _subdomainController = TextEditingController();
    _subdomainStore = getIt<SubdomainStore>();
  }

  @override
  void dispose() {
    _subdomainController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final subdomain = _subdomainController.text.trim();

    if (subdomain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subdomain')),
      );
      return;
    }

    await _subdomainStore.submitSubdomain(subdomain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Observer(
        builder: (_) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Your Subdomain',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the subdomain for your organization',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _subdomainController,
                  enabled: !_subdomainStore.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Subdomain',
                    hintText: 'e.g., mycompany',
                    prefixText: 'https://',
                    suffixText: '.erp.local',
                    errorText: _subdomainStore.errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _subdomainStore.isLoading ? null : _handleSubmit,
                    child: _subdomainStore.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
