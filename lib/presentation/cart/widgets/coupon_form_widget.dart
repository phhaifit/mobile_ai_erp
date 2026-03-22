import 'package:flutter/material.dart';

/// Widget for entering and applying coupon codes
class CouponFormWidget extends StatefulWidget {
  final ValueChanged<String> onApplyCoupon;
  final VoidCallback? onRemoveCoupon;
  final String? appliedCouponCode;
  final bool isLoading;
  final String? error;
  final String? success;

  const CouponFormWidget({
    Key? key,
    required this.onApplyCoupon,
    this.onRemoveCoupon,
    this.appliedCouponCode,
    this.isLoading = false,
    this.error,
    this.success,
  }) : super(key: key);

  @override
  State<CouponFormWidget> createState() => _CouponFormWidgetState();
}

class _CouponFormWidgetState extends State<CouponFormWidget> {
  late TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.appliedCouponCode ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleApply() {
    final code = _controller.text.trim().toUpperCase();
    if (code.isNotEmpty) {
      widget.onApplyCoupon(code);
    }
  }

  void _handleRemove() {
    _controller.clear();
    widget.onRemoveCoupon?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasAppliedCoupon = widget.appliedCouponCode != null &&
        widget.appliedCouponCode!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Apply Coupon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: hasAppliedCoupon ? Colors.green[600] : null,
                        ),
                      ),
                      if (hasAppliedCoupon) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.appliedCouponCode!),
                          backgroundColor: Colors.green[100],
                          labelStyle: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          onDeleted: _handleRemove,
                        ),
                      ],
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
            // Expanded content
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 16),
              // Input field
              TextField(
                controller: _controller,
                enabled: !hasAppliedCoupon,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Error message
              if (widget.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.error!,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Success message
              if (widget.success != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[200]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.success!,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Apply Coupon',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Available coupons list widget
class AvailableCouponsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final ValueChanged<String> onSelectCoupon;
  final bool isLoading;

  const AvailableCouponsWidget({
    Key? key,
    required this.coupons,
    required this.onSelectCoupon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Available Coupons',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...coupons.map((coupon) {
          return GestureDetector(
            onTap: isLoading ? null : () => onSelectCoupon(coupon['code']),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['code'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            coupon['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.blue[600]),
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
