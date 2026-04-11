import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:intl/intl.dart';

class FulfillmentListScreen extends StatefulWidget {
  @override
  State<FulfillmentListScreen> createState() => _FulfillmentListScreenState();
}

class _FulfillmentListScreenState extends State<FulfillmentListScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

  @override
  void initState() {
    super.initState();
    _store.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Fulfillment'),
      ),
      body: Column(
        children: [
          _buildStatusFilterChips(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips() {
    return Observer(
      builder: (_) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildChip(null, 'All'),
              ...FulfillmentStatus.values.map(
                (status) => _buildChip(status, status.displayName),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(FulfillmentStatus? status, String label) {
    final isSelected = _store.statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _store.setStatusFilter(status),
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOrderList() {
    return Observer(
      builder: (_) {
        if (_store.isLoadingOrders) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = _store.filteredOrders;
        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(FulfillmentOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _store.getOrderDetail(order.id);
          Navigator.of(context).pushNamed(
            Routes.fulfillmentDetail,
            arguments: order.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.code,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(order.customerName,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.storefront,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(order.source,
                      style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  Text(
                    '${order.itemCount} items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currencyFormat.format(order.totalAmount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(FulfillmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return Colors.orange;
      case FulfillmentStatus.processing:
        return Colors.blue;
      case FulfillmentStatus.shipped:
        return Colors.teal;
      case FulfillmentStatus.delivered:
        return Colors.green;
      case FulfillmentStatus.cancelled:
        return Colors.red;
      case FulfillmentStatus.returned:
        return Colors.grey;
    }
  }
}
