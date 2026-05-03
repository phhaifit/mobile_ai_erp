import 'package:mobile_ai_erp/data/network/apis/dashboard/dashboard_api.dart';
import 'package:mobile_ai_erp/data/network/mappers/dashboard/dashboard_mapper.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';

/// Live implementation of [DashboardRepository] that fetches data from the
/// real backend snapshot API (ai-erp-be) via [DashboardApi].
///
/// Architecture: Network → DTO → Repository → Domain → Store
class LiveDashboardRepository extends DashboardRepository {
  final DashboardApi _api;

  LiveDashboardRepository(this._api);

  @override
  Future<DashboardSnapshot> loadDashboard(DashboardPeriod period) async {
    final dto = await _api.getSnapshot(
      period: period.name, // matches backend enum strings
    );
    return DashboardMapper.fromDto(dto);
  }
}
