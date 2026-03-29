import 'package:flutter/material.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final void Function(String method, String? savedCardId) onMethodSelected;
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
  // No default method - user must explicitly select a payment method
  // This ensures the visual state matches the actual checkout state

  static const List<Map<String, String>> _savedCards = [
    {
      'value': 'saved_visa_4242',
      'brand': 'Visa',
      'last4': '4242',
      'label': 'Personal card',
      'method': 'credit_card',
    },
    {
      'value': 'saved_mastercard_8888',
      'brand': 'Mastercard',
      'last4': '8888',
      'label': 'Work card',
      'method': 'credit_card',
    },
    {
      'value': 'saved_debit_vcb_1234',
      'brand': 'VCB Debit',
      'last4': '1234',
      'label': 'Vietcombank',
      'method': 'debit_card',
    },
  ];

  String? _selectedMethod;
  String? _selectedSavedCard;

  @override
  void initState() {
    super.initState();
    _selectedMethod = _normalizeMethod(widget.selectedMethod);
    _selectedSavedCard = _extractSavedCard(widget.selectedMethod);
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedMethod == widget.selectedMethod) return;

    final incoming = widget.selectedMethod?.trim();
    if (incoming == null || incoming.isEmpty) return;

    // Parent chỉ nên truyền method xuống đây.
    // Nếu lỡ truyền saved card thì vẫn map đúng method của card đó,
    // không ép cứng về credit_card nữa.
    final mappedMethod = _normalizeMethod(incoming);
    final mappedSavedCard = _extractSavedCard(incoming);

    if (mappedMethod == _selectedMethod &&
        mappedSavedCard == _selectedSavedCard) {
      return;
    }

    setState(() {
      _selectedMethod = mappedMethod;

      // Chỉ giữ selectedSavedCard nếu incoming thực sự là saved card
      // và nó thuộc đúng method hiện tại.
      if (mappedSavedCard != null &&
          _getMethodOfSavedCard(mappedSavedCard) == mappedMethod) {
        _selectedSavedCard = mappedSavedCard;
      } else if (!_savedCardBelongsToMethod(_selectedSavedCard, mappedMethod ?? '')) {
        _selectedSavedCard = null;
      }
    });
  }

  String? _normalizeMethod(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null; // No default - user must select

    if (_isSavedCardValue(raw)) {
      return _getMethodOfSavedCard(raw);
    }

    return raw;
  }

  String? _extractSavedCard(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    return _isSavedCardValue(raw) ? raw : null;
  }

  bool _isSavedCardValue(String value) => value.startsWith('saved_');

  bool _methodSupportsSavedCards(String? method) {
    if (method == null) return false;
    return method == 'credit_card' || method == 'debit_card';
  }

  String? _getMethodOfSavedCard(String cardValue) {
    for (final card in _savedCards) {
      if (card['value'] == cardValue) {
        return card['method'];
      }
    }
    return null;
  }

  bool _savedCardBelongsToMethod(String? cardValue, String? method) {
    if (cardValue == null || method == null) return false;
    return _getMethodOfSavedCard(cardValue) == method;
  }

  void _selectMethod(String method) {
    if (_selectedMethod == method) return;

    setState(() {
      _selectedMethod = method;

      if (!_savedCardBelongsToMethod(_selectedSavedCard, method)) {
        _selectedSavedCard = null;
      }
    });

    widget.onMethodSelected(method, null);
  }

  void _selectSavedCard(String cardValue) {
    final cardMethod = _getMethodOfSavedCard(cardValue);

    setState(() {
      if (cardMethod != null) {
        _selectedMethod = cardMethod;
      }
      _selectedSavedCard = cardValue;
    });

    // cardMethod is guaranteed non-null for valid saved cards
    widget.onMethodSelected(cardMethod ?? _selectedMethod ?? '', cardValue);
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
              icon: Icons.payment,
              subtitle: 'Pay directly from your bank account',
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 'digital_wallet',
              title: 'Digital Wallet',
              icon: Icons.account_balance_wallet_outlined,
              subtitle: 'MoMo, ZaloPay, Apple Pay, Google Pay',
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 'bank_transfer',
              title: 'Bank Transfer',
              icon: Icons.account_balance_outlined,
              subtitle: 'Manual transfer to our bank account',
            ),
            const SizedBox(height: 12),

            _buildPaymentOption(
              value: 'cod',
              title: 'Cash on Delivery',
              icon: Icons.local_shipping,
              subtitle: 'Pay with cash when you receive your order',
            ),

            if (widget.showSavedCards &&
                _methodSupportsSavedCards(_selectedMethod)) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _selectMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              onChanged: (v) {
                if (v != null) _selectMethod(v);
              },
            ),
            const SizedBox(width: 8),
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[800] : null,
                    ),
                  ),
                  const SizedBox(height: 2),
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
    );
  }

  Widget _buildSavedCardsSection() {
    final availableCards = _savedCards.where((card) {
      return card['method'] == _selectedMethod;
    }).toList();

    if (availableCards.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accounts',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'No saved accounts for this payment method.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accounts',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...availableCards.map((card) {
          final cardValue = card['value']!;
          final isSelected = _selectedSavedCard == cardValue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectSavedCard(cardValue),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: cardValue,
                      groupValue: _selectedSavedCard,
                      onChanged: (v) {
                        if (v != null) _selectSavedCard(v);
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.credit_card,
                      color: isSelected ? Colors.blue : Colors.grey[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${card['brand']} •••• ${card['last4']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
