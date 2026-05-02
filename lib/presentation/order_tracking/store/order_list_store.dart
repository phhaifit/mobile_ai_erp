import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/orders_api.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_list_response.dart';
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

  @observable
  int currentPage = 1;

  @observable
  int totalPages = 1;

  @observable
  int totalItems = 0;

  @observable
  int pageSize = 20;

  @computed
  bool get hasMoreOrders => currentPage < totalPages;

  @action
  Future<void> loadOrders({int page = 1, bool append = false}) async {
    isLoading = true;
    error = null;

    if (useMockData) {
      orders = ObservableList<dynamic>.of(_mockOrders);
      isLoading = false;
      return;
    }

    try {
      const String envSecretKey = String.fromEnvironment(
        'ERP_SECRET_KEY',
        defaultValue: '',
      );
      final String? secretKey = _resolveHeaderValue(envSecretKey);
      final String? tenantId = _resolveHeaderValue(Endpoints.tenantId);

      if (secretKey == null) {
        error = 'Missing ERP secret key. Pass --dart-define=ERP_SECRET_KEY=...';
        errorStore.setErrorMessage(error ?? 'Missing ERP secret key.');
        return;
      }

      final response = await _ordersApi.getOrders(
        pageSize: pageSize,
        page: page,
        secretKey: secretKey,
        tenantId: tenantId,
      );

      // Extract orders and pagination metadata from response
      final OrderListResponse parsedResponse = _parseOrderListResponse(
        response,
      );

      // Convert OrderSummaryDto to Map for compatibility with existing getter methods
      final List<Map<String, dynamic>> orderMaps = parsedResponse.data
          .map(_orderSummaryDtoToMap)
          .toList();

      if (append) {
        orders.addAll(orderMaps);
      } else {
        orders = ObservableList<dynamic>.of(orderMaps);
      }

      currentPage = parsedResponse.meta.page;
      totalPages = parsedResponse.meta.totalPages;
      totalItems = parsedResponse.meta.totalItems;
    } catch (e) {
      error = 'Failed to load orders. ${e.toString()}';
      errorStore.setErrorMessage(error ?? 'Failed to load orders.');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMoreOrders() async {
    if (!hasMoreOrders || isLoading) return;
    await loadOrders(page: currentPage + 1, append: true);
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

  OrderListResponse _parseOrderListResponse(dynamic response) {
    try {
      if (response is Map<String, dynamic>) {
        final parsed = OrderListResponse.fromJson(response);
        return parsed;
      }
      // Fallback for non-standard responses
      throw Exception('Invalid response format');
    } catch (e) {
      // If parsing fails, create a response with default pagination
      final List<dynamic> orders = _extractOrders(response);
      return OrderListResponse(
        data: orders
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderSummaryDto.fromJson(e))
            .toList(),
        meta: PaginationMeta(
          page: 1,
          pageSize: pageSize,
          totalItems: orders.length,
          totalPages: 1,
        ),
      );
    }
  }

  /// Convert OrderSummaryDto to a Map for compatibility with existing getter methods
  Map<String, dynamic> _orderSummaryDtoToMap(OrderSummaryDto dto) {
    return {
      'id': dto.id,
      'code': dto.code,
      'status': dto.status,
      'paymentStatus': dto.paymentStatus,
      'customerName': dto.customerName,
      'totalPrice': dto.totalAmount,
      'createdAt': dto.createdAt,
      'totalItems': dto.totalItems,
      'totalQuantity': dto.totalQuantity,
    };
  }
}
