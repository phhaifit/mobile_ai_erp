import 'package:flutter/material.dart';
import '../../../domain/entity/storefront_order/order.dart';
import '../../../../di/service_locator.dart';
import '../store/order_store.dart';

class CancelOrderScreen extends StatefulWidget {
  const CancelOrderScreen({super.key});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _selectedReason = 'Changed my mind';
  bool _isLoading = false;

  // Custom cancellation reasons
  final List<String> _reasons = [
    'Changed my mind',
    'Found a better price or coupon',
    'Ordered by mistake',
    'Shipping time is too long',
    'Need to change shipping address',
    'Other'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! StorefrontOrder) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Order details not found.')),
      );
    }
    
    final order = args;
    final orderStore = getIt<OrderStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cancel Order: #${order.code}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('You can only cancel orders that have not yet been packed or shipped.',
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 24),
              
              // Reason Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: const InputDecoration(
                    labelText: 'Reason for Cancellation',
                    border: OutlineInputBorder()),
                items: _reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (String? newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Additional Details
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                enabled: !_isLoading,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // If they select "Other", force them to type a reason
                  if (_selectedReason == 'Other' && (value == null || value.trim().isEmpty)) {
                    return 'Please provide a reason for cancellation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red, // Red for destructive action
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            
                            // Combine the reason for the backend
                            final finalReason = '$_selectedReason: ${_reasonController.text}'.trim();
                            
                            try {
                              // Call the existing store method
                              // Note: If you want to send `finalReason` to the backend, 
                              // you will need to update `orderStore.cancelOrder` to accept a reason string.
                              await orderStore.cancelOrder(order.id);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Order has been cancelled successfully.')),
                                );
                                // Pop twice to go back to the Order History list
                                Navigator.of(context).pop(); 
                                Navigator.of(context).pop(); 
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to cancel order: $e')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Cancellation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}