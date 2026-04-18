import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/coupon.dart';

class CouponFormWidget extends StatefulWidget {
  final List<Coupon> coupons;
  final ValueChanged<String> onApplyCoupon;
  final VoidCallback? onRemoveCoupon;
  final String? appliedCouponCode;
  final bool isLoading;
  final String? error;
  final String? success;

  const CouponFormWidget({
    Key? key,
    required this.coupons,
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
  bool _isExpanded = false;
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.appliedCouponCode;
  }

  @override
  void didUpdateWidget(covariant CouponFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appliedCouponCode != oldWidget.appliedCouponCode) {
      _selectedCode = widget.appliedCouponCode;
    }
  }

  void _handleApply() {
    final code = _selectedCode?.trim();
    if (code != null && code.isNotEmpty) {
      widget.onApplyCoupon(code);
    }
  }

  void _handleRemove() {
    setState(() {
      _selectedCode = null;
    });
    widget.onRemoveCoupon?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasAppliedCoupon =
        widget.appliedCouponCode != null &&
        widget.appliedCouponCode!.isNotEmpty;

    final selectedCoupon = widget.coupons
        .where((coupon) => coupon.code == _selectedCode)
        .cast<Coupon?>()
        .firstWhere((coupon) => coupon != null, orElse: () => null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: Colors.blue[600],
                        ),
                        Text(
                          'Apply Coupon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: hasAppliedCoupon ? Colors.green[600] : null,
                          ),
                        ),
                        if (hasAppliedCoupon)
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: hasAppliedCoupon
                    ? widget.appliedCouponCode
                    : _selectedCode,
                items: widget.coupons.map((coupon) {
                  return DropdownMenuItem<String>(
                    value: coupon.code,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          coupon.code,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if ((coupon.name).isNotEmpty)
                          Text(
                            coupon.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: hasAppliedCoupon || widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCode = value;
                        });
                      },
                decoration: InputDecoration(
                  hintText: 'Select coupon',
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

              if (selectedCoupon != null && !hasAppliedCoupon) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedCoupon.name.isNotEmpty)
                        Text(
                          selectedCoupon.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      if ((selectedCoupon.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          selectedCoupon.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

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
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[600],
                        ),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      widget.isLoading ||
                          hasAppliedCoupon ||
                          _selectedCode == null
                      ? null
                      : _handleApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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

class AvailableCouponsWidget extends StatelessWidget {
  final List<Coupon> coupons;
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
      return const SizedBox.shrink();
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
            onTap: isLoading ? null : () => onSelectCoupon(coupon.code),
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
                            coupon.code,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if ((coupon.description ?? '').isNotEmpty)
                            Text(
                              coupon.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.blue[600],
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
