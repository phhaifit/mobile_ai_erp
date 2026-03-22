import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/model/reports_models.dart';
import 'package:mobx/mobx.dart';

part 'reports_store.g.dart';

class ReportsStore = _ReportsStore with _$ReportsStore;

abstract class _ReportsStore with Store {
  _ReportsStore(this._repository, this.errorStore);

  final ReportsMockRepository _repository;
  final ErrorStore errorStore;

  int _requestId = 0;

  @observable
  bool isLoading = false;

  @observable
  ReportFilter selectedFilter = const ReportFilter(
    label: 'Last 30 days',
    period: ReportPeriod.monthly,
    dateRangeLabel: 'Feb 20 - Mar 21',
  );

  @observable
  ReportsDashboardData? dashboard;

  @action
  Future<void> loadDashboard() async {
    final requestId = ++_requestId;
    isLoading = true;

    try {
      final data = await _repository.loadDashboard(selectedFilter);
      if (requestId != _requestId) {
        return;
      }

      dashboard = data;
      errorStore.setErrorMessage('');
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }

      errorStore.setErrorMessage('Unable to load reports dashboard');
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
      }
    }
  }

  @action
  Future<void> changePeriod(ReportPeriod period) async {
    selectedFilter = _filterFor(period);
    await loadDashboard();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

  @action
  Future<void> exportJob(int index) async {
    final currentDashboard = dashboard;
    if (currentDashboard == null ||
        index >= currentDashboard.exportJobs.length) {
      return;
    }

    final jobs = List<ExportJob>.from(currentDashboard.exportJobs);
    jobs[index] = jobs[index].copyWith(
      status: ExportJobStatus.completed,
      updatedAt: 'Generated just now',
    );

    dashboard = currentDashboard.copyWith(exportJobs: jobs);
  }

  ReportFilter _filterFor(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.weekly:
        return const ReportFilter(
          label: 'This week',
          period: ReportPeriod.weekly,
          dateRangeLabel: 'Mar 17 - Mar 23',
        );
      case ReportPeriod.monthly:
        return const ReportFilter(
          label: 'Last 30 days',
          period: ReportPeriod.monthly,
          dateRangeLabel: 'Feb 20 - Mar 21',
        );
      case ReportPeriod.quarterly:
        return const ReportFilter(
          label: 'Current quarter',
          period: ReportPeriod.quarterly,
          dateRangeLabel: 'Jan 1 - Mar 21',
        );
      case ReportPeriod.yearly:
        return const ReportFilter(
          label: 'Year to date',
          period: ReportPeriod.yearly,
          dateRangeLabel: 'Jan 1 - Dec 31',
        );
    }
  }
}
