import 'package:flutter/material.dart';

/// Widget for selecting payment method
class PaymentMethodsWidget extends StatefulWidget {
  final ValueChanged<String> onMethodSelected;
  final String? selectedMethod;
  final bool showSavedCards;

  const PaymentMethodsWidget({
    Key? key,
    required this.onMethodSelected,
    this.selectedMethod,
    this.showSavedCards = true,
  }) : super(key: key);

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  late String _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod ?? 'credit_card';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Credit Card option
            _buildPaymentOption(
              value: 'credit_card',
              title: 'Credit Card',
              icon: Icons.credit_card,
              subtitle: 'Visa, Mastercard, American Express',
            ),
            const SizedBox(height: 12),
            // Debit Card option
            _buildPaymentOption(
              value: 'debit_card',
              title: 'Debit Card',
              icon: Icons.card_giftcard,
              subtitle: 'Debit card from your bank',
            ),
            const SizedBox(height: 12),
            // Digital Wallet option
            _buildPaymentOption(
              value: 'digital_wallet',
              title: 'Digital Wallet',
              icon: Icons.account_balance_wallet,
              subtitle: 'Google Pay, Apple Pay, PayPal',
            ),
            const SizedBox(height: 12),
            // Bank Transfer option
            _buildPaymentOption(
              value: 'bank_transfer',
              title: 'Bank Transfer',
              icon: Icons.account_balance,
              subtitle: 'Direct bank transfer',
            ),
            if (widget.showSavedCards) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 16),
              _buildSavedCardsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    return Material(
      child: InkWell(
        onTap: () {
          setState(() => _selectedMethod = value);
          widget.onMethodSelected(value);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedMethod == value
                  ? Colors.blue[600]!
                  : Colors.grey[300]!,
              width: _selectedMethod == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                _selectedMethod == value ? Colors.blue[50] : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedMethod,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMethod = val);
                    widget.onMethodSelected(val);
                  }
                },
              ),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsSection() {
    // Mock saved cards data
    final savedCards = [
      {
        'id': 'card_1',
        'lastDigits': '4242',
        'brand': 'Visa',
        'expiryMonth': 12,
        'expiryYear': 25,
      },
      {
        'id': 'card_2',
        'lastDigits': '5555',
        'brand': 'Mastercard',
        'expiryMonth': 8,
        'expiryYear': 26,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Cards',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ...savedCards.map((card) {
          final cardValue = 'saved_${card['id']}';
          return GestureDetector(
            onTap: () {
              setState(() => _selectedMethod = cardValue);
              widget.onMethodSelected(cardValue);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Radio<String>(
                      value: cardValue,
                      groupValue: _selectedMethod,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMethod = val);
                          widget.onMethodSelected(val);
                        }
                      },
                    ),
                    Icon(Icons.credit_card, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${card['brand']} •••• ${card['lastDigits']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Expires ${card['expiryMonth']}/${card['expiryYear']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
