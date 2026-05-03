import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/dto/dashboard/dashboard_snapshot_dto.dart';

class DashboardApi {
  static const String _snapshotPath = '/erp/dashboard/snapshot';

  final DioClient _dioClient;

  DashboardApi(this._dioClient);

  /// Fetches a dashboard snapshot for the given [period].
  ///
  /// Backend: GET /erp/dashboard/snapshot?period=daily|weekly|monthly
  /// The optional [warehouseId] is forwarded when the app has warehouse context.
  Future<DashboardSnapshotDto> getSnapshot({
    String? period,
    String? warehouseId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;
    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;

    final response = await _dioClient.dio.get(
      _snapshotPath,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return DashboardSnapshotDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
