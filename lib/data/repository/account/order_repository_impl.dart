import '../../../domain/entity/order/order.dart';
import '../../../domain/repository/account/order_repository.dart';
import '../../local/datasources/account/order_mock_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderMockDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<List<Order>> getOrderHistory() => _dataSource.getOrderHistory();
}