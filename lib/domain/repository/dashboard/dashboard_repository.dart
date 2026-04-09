import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> loadDashboard(DashboardPeriod period);
}
