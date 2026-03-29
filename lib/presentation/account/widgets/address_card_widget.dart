import 'package:flutter/material.dart';
import '../../../../domain/entity/address/address.dart';

class AddressCardWidget extends StatelessWidget {
  final Address address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCardWidget({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: address.isDefault ? Colors.blue : Colors.grey.shade300,
            width: address.isDefault ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // 3. Added to keep the badge at the top if the name spans multiple lines
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    address.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8), // Added spacing between long text and badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Default',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 8),
            Text(address.phone, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('${address.street}, ${address.city}',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, // <-- Add this to force full width
              child: Wrap(
                alignment: WrapAlignment.end, // <-- Now this will properly push to the right
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  if (!address.isDefault)
                    _AddressCardButton(
                      label: "Set as Default", 
                      onPressed: onSetDefault,
                    ),
                  _AddressCardButton(
                    label: "Edit", 
                    onPressed: onEdit,
                  ),
                  // We will leave the delete button here, but wire it up in the Address Book!
                  _AddressCardButton(
                    label: "Delete", 
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AddressCardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _AddressCardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color ?? Colors.grey.shade400),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}