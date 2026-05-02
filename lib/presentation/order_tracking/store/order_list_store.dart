import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/orders_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';

part 'order_list_store.g.dart';

class OrderListStore = _OrderListStore with _$OrderListStore;

abstract class _OrderListStore with Store {
  _OrderListStore(this._ordersApi, this.errorStore);

  final OrdersApi _ordersApi;
  final ErrorStore errorStore;

  // Mock mode: set to false when you want real API calls.
  static const bool useMockData = false;

  final List<Map<String, dynamic>> _mockOrders = const [
    {
      'code': 'ORD-DEMO-001',
      'status': 'pending',
      'totalPrice': '110000',
      'customerName': 'Nguyen Van A',
    },
    {
      'code': 'ORD-DEMO-002',
      'status': 'shipped',
      'totalPrice': '245000',
      'customerName': 'Tran Thi B',
    },
    {
      'code': 'ORD-DEMO-003',
      'status': 'delivered',
      'totalPrice': '88000',
      'customerName': 'Le Van C',
    },
  ];

  @observable
  ObservableList<dynamic> orders = ObservableList<dynamic>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  dynamic selectedOrder;

  @action
  Future<void> loadOrders() async {
    isLoading = true;
    error = null;

    if (useMockData) {
      orders = ObservableList<dynamic>.of(_mockOrders);
      isLoading = false;
      return;
    }

    try {
      final response = await _ordersApi.getOrders(pageSize: 20, page: 1);

      final List<dynamic> parsed = _extractOrders(response);
      orders = ObservableList<dynamic>.of(parsed);
    } catch (e) {
      error = 'Failed to load orders. ${e.toString()}';
      errorStore.setErrorMessage(error ?? 'Failed to load orders.');
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectOrder(dynamic order) {
    selectedOrder = order;
  }

  @action
  void clearSelected() {
    selectedOrder = null;
  }

  String getOrderCode(dynamic order) {
    if (order is Map<String, dynamic>) {
      return (order['code'] ?? order['orderCode'] ?? order['id'] ?? 'N/A')
          .toString();
    }
    return 'N/A';
  }

  String getOrderId(dynamic order) {
    if (order is Map<String, dynamic>) {
      return (order['id'] ?? order['orderId'] ?? order['code'] ?? '')
          .toString();
    }
    return '';
  }

  String getOrderStatus(dynamic order) {
    if (order is Map<String, dynamic>) {
      return (order['status'] ?? order['state'] ?? 'unknown').toString();
    }
    return 'unknown';
  }

  String getTotalPrice(dynamic order) {
    if (order is Map<String, dynamic>) {
      final price =
          order['totalPrice'] ?? order['total'] ?? order['totalAmount'];
      if (price != null) {
        return price.toString();
      }
    }
    return '0';
  }

  String getCustomerName(dynamic order) {
    if (order is Map<String, dynamic>) {
      final dynamic customer = order['customer'];
      if (customer is Map<String, dynamic>) {
        return (customer['name'] ?? customer['fullName'] ?? 'Unknown')
            .toString();
      }

      return (order['customerName'] ?? order['customer'] ?? 'Unknown')
          .toString();
    }
    return 'Unknown';
  }

  int getItemsCount(dynamic order) {
    if (order is Map<String, dynamic>) {
      final dynamic items =
          order['items'] ?? order['orderItems'] ?? order['products'];
      if (items is List) {
        return items.length;
      }

      final dynamic count =
          order['itemsCount'] ?? order['items_count'] ?? order['totalItems'];
      if (count is num) {
        return count.toInt();
      }
      if (count is String) {
        return int.tryParse(count) ?? 0;
      }
    }

    return 0;
  }

  String getDeliveryInfo(dynamic order) {
    if (order is Map<String, dynamic>) {
      final dynamic shipping =
          order['shippingAddress'] ?? order['deliveryAddress'];
      if (shipping is Map<String, dynamic>) {
        final String line1 =
            (shipping['addressLine1'] ??
                    shipping['line1'] ??
                    shipping['address'] ??
                    '')
                .toString();
        final String city = (shipping['city'] ?? shipping['province'] ?? '')
            .toString();
        final String combined = [
          line1,
          city,
        ].where((e) => e.isNotEmpty).join(', ');
        if (combined.isNotEmpty) {
          return combined;
        }
      }

      final String fallback =
          (order['shippingAddress'] ?? order['deliveryAddress'] ?? '')
              .toString();
      if (fallback.isNotEmpty) {
        return fallback;
      }
    }

    return '';
  }

  DateTime? getOrderCreatedAt(dynamic order) {
    if (order is Map<String, dynamic>) {
      final raw =
          order['createdAt'] ?? order['created_at'] ?? order['createdDate'];
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw);
      }
    }
    return null;
  }

  String? _resolveHeaderValue(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  List<dynamic> _extractOrders(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final dynamic data = response['data'];
      if (data is List) {
        return data;
      }

      final dynamic items = response['items'];
      if (items is List) {
        return items;
      }

      return [response];
    }

    return <dynamic>[];
  }
}
