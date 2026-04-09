import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';

part 'dashboard_store.g.dart';

// ignore: library_private_types_in_public_api
class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  _DashboardStore(this._repository, this.errorStore);

  final DashboardRepository _repository;
  final ErrorStore errorStore;

  int _requestId = 0;

  @observable
  bool isLoading = false;

  @observable
  DashboardPeriod period = DashboardPeriod.weekly;

  @observable
  ObservableList<DashboardKpi> kpis = ObservableList<DashboardKpi>();

  @observable
  ObservableList<PendingTaskItem> pendingTasks =
      ObservableList<PendingTaskItem>();

  @observable
  ObservableList<SalesDataPoint> salesSeries = ObservableList<SalesDataPoint>();

  @observable
  ObservableList<InsightItem> insights = ObservableList<InsightItem>();

  @observable
  ObservableList<QuickNavItem> quickNavItems = ObservableList<QuickNavItem>();

  @observable
  DateTime? generatedAt;

  @observable
  String errorMessage = '';

  @computed
  int get totalPending => pendingTasks.length;

  @computed
  int get criticalPendingCount => pendingTasks
      .where((item) => item.priority == DashboardTaskPriority.critical)
      .length;

  @computed
  bool get hasData => kpis.isNotEmpty || pendingTasks.isNotEmpty;

  @action
  Future<void> loadDashboard() async {
    final requestId = ++_requestId;
    isLoading = true;

    try {
      final snapshot = await _repository.loadDashboard(period);
      if (requestId != _requestId) {
        return;
      }

      kpis = ObservableList<DashboardKpi>.of(snapshot.kpis);
      pendingTasks = ObservableList<PendingTaskItem>.of(snapshot.pendingTasks);
      salesSeries = ObservableList<SalesDataPoint>.of(snapshot.salesSeries);
      insights = ObservableList<InsightItem>.of(snapshot.insights);
      quickNavItems = ObservableList<QuickNavItem>.of(snapshot.quickNavItems);
      generatedAt = snapshot.generatedAt;
      errorMessage = '';
      errorStore.setErrorMessage('');
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }
      errorMessage = 'Unable to load dashboard';
      errorStore.setErrorMessage('Unable to load dashboard');
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
      }
    }
  }

  @action
  Future<void> setPeriod(DashboardPeriod value) async {
    if (period == value) {
      return;
    }
    period = value;
    await loadDashboard();
  }
}
