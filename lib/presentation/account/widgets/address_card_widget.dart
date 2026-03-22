import 'package:flutter/material.dart';
import '../../../../domain/entity/address/address.dart';

class AddressCardWidget extends StatelessWidget {
  final Address address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;

  const AddressCardWidget({
    Key? key,
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Highlight the border in blue if it is the default address
        side: BorderSide(
          color: address.isDefault ? Colors.blue : Colors.grey.shade300, 
          width: address.isDefault ? 2 : 1
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Default', 
                      style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.phone, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('${address.street}, ${address.city}', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as Default'),
                  ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}