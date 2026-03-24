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
  String? _selectedSavedCard;

  @override
  void initState() {
    super.initState();

    final initialValue = widget.selectedMethod ?? 'credit_card';

    if (initialValue.startsWith('saved_')) {
      _selectedMethod = 'credit_card';
      _selectedSavedCard = initialValue;
    } else {
      _selectedMethod = initialValue;
      _selectedSavedCard = null;
    }
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedMethod != widget.selectedMethod) {
      final newValue = widget.selectedMethod ?? 'credit_card';

      if (newValue.startsWith('saved_')) {
        _selectedMethod = 'credit_card';
        _selectedSavedCard = newValue;
      } else {
        _selectedMethod = newValue;
        _selectedSavedCard = null;
      }
    }
  }

  void _selectPaymentMethod(String value) {
    setState(() {
      _selectedMethod = value;
      _selectedSavedCard = null;
    });
    widget.onMethodSelected(value);
  }

  void _selectSavedCard(String cardValue) {
    setState(() {
      _selectedMethod = 'credit_card';
      _selectedSavedCard = cardValue;
    });
    widget.onMethodSelected(cardValue);
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildPaymentOption(
              value: 'credit_card',
              title: 'Credit Card',
              icon: Icons.credit_card,
              subtitle: 'Visa, Mastercard, American Express',
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 'debit_card',
              title: 'Debit Card',
              icon: Icons.card_giftcard,
              subtitle: 'Debit card from your bank',
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 'digital_wallet',
              title: 'Digital Wallet',
              icon: Icons.account_balance_wallet,
              subtitle: 'Google Pay, Apple Pay, PayPal',
            ),
            const SizedBox(height: 12),

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
    final isSelected = _selectedMethod == value;

    return Material(
      child: InkWell(
        onTap: () => _selectPaymentMethod(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue[50] : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedMethod,
                onChanged: (val) {
                  if (val != null) {
                    _selectPaymentMethod(val);
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        Text('Saved Cards', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        ...savedCards.map((card) {
          final cardValue = 'saved_${card['id']}';
          final isSelected = _selectedSavedCard == cardValue;

          return GestureDetector(
            onTap: () => _selectSavedCard(cardValue),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Radio<String>(
                      value: cardValue,
                      groupValue: _selectedSavedCard,
                      onChanged: (val) {
                        if (val != null) {
                          _selectSavedCard(val);
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
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue[600],
                        size: 20,
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
