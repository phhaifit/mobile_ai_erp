import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/model/reports_models.dart';
import 'package:mobx/mobx.dart';

class ReportsStore {
  ReportsStore(this._repository, this.errorStore);

  final ReportsMockRepository _repository;
  final ErrorStore errorStore;

  final Observable<bool> _isLoading = Observable(false);
  final Observable<ReportFilter> _selectedFilter = Observable(
    const ReportFilter(
      label: 'Last 30 days',
      period: ReportPeriod.monthly,
      dateRangeLabel: 'Feb 20 - Mar 21',
    ),
  );
  final Observable<ReportsDashboardData?> _dashboard = Observable(null);

  bool get isLoading => _isLoading.value;
  ReportFilter get selectedFilter => _selectedFilter.value;
  ReportsDashboardData? get dashboard => _dashboard.value;

  Future<void> loadDashboard() async {
    final action = Action(() => _isLoading.value = true);
    action();

    try {
      final data = await _repository.loadDashboard(selectedFilter);
      runInAction(() {
        _dashboard.value = data;
        errorStore.setErrorMessage('');
      });
    } catch (_) {
      runInAction(() {
        errorStore.setErrorMessage('Unable to load reports dashboard');
      });
    } finally {
      runInAction(() {
        _isLoading.value = false;
      });
    }
  }

  Future<void> changePeriod(ReportPeriod period) async {
    final nextFilter = _filterFor(period);
    runInAction(() {
      _selectedFilter.value = nextFilter;
    });
    await loadDashboard();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

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

    runInAction(() {
      _dashboard.value = currentDashboard.copyWith(exportJobs: jobs);
    });
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
