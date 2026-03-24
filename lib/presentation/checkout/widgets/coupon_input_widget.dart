import 'package:flutter/material.dart';

/// Widget for entering and applying coupon codes
class CouponInputWidget extends StatefulWidget {
  const CouponInputWidget({
    super.key,
    required this.onApplyCoupon,
    this.onRemoveCoupon,
    this.appliedCouponCode,
    this.isValidating = false,
    this.errorMessage,
  });

  final Future<bool> Function(String code) onApplyCoupon;
  final VoidCallback? onRemoveCoupon;
  final String? appliedCouponCode;
  final bool isValidating;
  final String? errorMessage;

  @override
  State<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends State<CouponInputWidget> {
  final TextEditingController _couponController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _handleApply() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final success = await widget.onApplyCoupon(code);
    if (success && mounted) {
      _couponController.clear();
      setState(() => _isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Show applied coupon if exists
    if (widget.appliedCouponCode != null) {
      return _buildAppliedCoupon(context);
    }

    // Show input form
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Have a coupon code?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: widget.errorMessage,
                    suffixIcon: widget.isValidating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _handleApply(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: widget.isValidating ? null : _handleApply,
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAppliedCoupon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coupon Applied',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                ),
                Text(
                  widget.appliedCouponCode!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (widget.onRemoveCoupon != null)
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              onPressed: widget.onRemoveCoupon,
              tooltip: 'Remove coupon',
            ),
        ],
      ),
    );
  }
}
