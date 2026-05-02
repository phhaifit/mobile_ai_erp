import 'package:flutter/material.dart';
import '../../../../domain/entity/supplier/supplier.dart';

class SupplierInfoCard extends StatelessWidget {
  final Supplier supplier;
  const SupplierInfoCard({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Information',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: 20),
            if (supplier.code.isNotEmpty)
              _InfoRow(
                  icon: Icons.tag_outlined,
                  label: 'Code',
                  value: supplier.code),
            if (supplier.phone != null && supplier.phone!.isNotEmpty)
              _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: supplier.phone!),
            if (supplier.email != null && supplier.email!.isNotEmpty)
              _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: supplier.email!),
            if (supplier.address != null && supplier.address!.isNotEmpty)
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: supplier.address!),
            if (supplier.taxCode != null && supplier.taxCode!.isNotEmpty)
              _InfoRow(
                  icon: Icons.receipt_outlined,
                  label: 'Tax Code',
                  value: supplier.taxCode!),
            if (supplier.idCard != null && supplier.idCard!.isNotEmpty)
              _InfoRow(
                  icon: Icons.card_membership_outlined,
                  label: 'ID Card',
                  value: supplier.idCard!),
            if (supplier.bankName != null && supplier.bankName!.isNotEmpty)
              _InfoRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Bank Name',
                  value: supplier.bankName!),
            if (supplier.bankAccount != null && supplier.bankAccount!.isNotEmpty)
              _InfoRow(
                  icon: Icons.wallet_outlined,
                  label: 'Bank Account',
                  value: supplier.bankAccount!),
            if (supplier.bankNote != null && supplier.bankNote!.isNotEmpty)
              _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Bank Note',
                  value: supplier.bankNote!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.5)),
          const SizedBox(width: 10),
          SizedBox(
              width: 110,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.5)))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
