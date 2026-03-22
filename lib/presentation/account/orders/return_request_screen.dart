import 'package:flutter/material.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../di/service_locator.dart';
import '../store/order_store.dart';

class ReturnRequestScreen extends StatefulWidget {
  const ReturnRequestScreen({Key? key}) : super(key: key);

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _selectedReason = 'Damaged Item';

  final List<String> _reasons = [
    'Damaged Item',
    'Wrong Item Received',
    'Missing Parts',
    'Other'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    final orderStore = getIt<OrderStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return / Exchange'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request for Order: ${order.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                    labelText: 'Reason for Return',
                    border: OutlineInputBorder()),
                items: _reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.upload_file, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to upload photo evidence (Mock)',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await orderStore.submitReturnRequest(
                          order.id, _selectedReason);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Return request submitted successfully!')),
                        );
                        Navigator.pop(context); // Go back to order details
                      }
                    }
                  },
                  child: const Text('Submit Request',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
