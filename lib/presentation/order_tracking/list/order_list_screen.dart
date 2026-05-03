import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/store/order_list_store.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/utils/order_tracking_order_info.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/order_tracking_shared_widgets.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderListStore _orderListStore = getIt<OrderListStore>();

  @override
  void initState() {
    super.initState();
    _orderListStore.loadOrders();
  }

  @override
  void dispose() {
    _orderListStore.clearSelected();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat currencyFormat = NumberFormat.decimalPattern('vi_VN');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Observer(
        builder: (context) {
          if (_orderListStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_orderListStore.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _orderListStore.error ?? 'Error loading orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _orderListStore.loadOrders();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_orderListStore.orders.isEmpty) {
            return Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _orderListStore.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = _orderListStore.orders[index];
              final OrderInfo info = OrderInfoMapper.fromSummary(order);

              return _buildOrderCard(
                context: context,
                colorScheme: colorScheme,
                textTheme: textTheme,
                currencyFormat: currencyFormat,
                orderId: info.id,
                orderCode: info.code,
                status: info.status,
                customerName: info.customerName,
                totalPrice: info.totalPrice,
                createdAt: info.createdAt,
                itemsCount: info.itemsCount,
                deliveryInfo: info.deliveryInfo,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required NumberFormat currencyFormat,
    required String orderId,
    required String orderCode,
    required String status,
    required String customerName,
    required String totalPrice,
    required DateTime? createdAt,
    required int itemsCount,
    required String deliveryInfo,
  }) {
    final Color statusColor = getOrderStatusColor(status, colorScheme);
    final String priceLabel = formatOrderPrice(totalPrice, currencyFormat);
    final String dateLabel = createdAt == null
        ? ''
        : DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    final String itemsLabel = itemsCount > 0 ? '$itemsCount items' : '';

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: orderId.isEmpty
            ? () {
                _showSnackBar(context, 'Order ID is missing.');
              }
            : () {
                Navigator.of(
                  context,
                ).pushNamed('/order-tracking', arguments: {'orderId': orderId});
              },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderCode,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          customerName,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (deliveryInfo.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            deliveryInfo,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.65),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(
                        label: formatOrderStatus(status),
                        background: statusColor,
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InfoRow(
                      label: 'Total',
                      value: '$priceLabel đ',
                      valueStyle: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (itemsLabel.isNotEmpty)
                    Expanded(
                      child: InfoRow(
                        label: 'Items',
                        value: itemsLabel,
                        alignEnd: true,
                        valueStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )
                  else if (dateLabel.isNotEmpty)
                    Expanded(
                      child: InfoRow(
                        label: 'Created',
                        value: dateLabel,
                        alignEnd: true,
                        valueStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
              if (itemsLabel.isNotEmpty && dateLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                InfoRow(
                  label: 'Created',
                  value: dateLabel,
                  valueStyle: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
