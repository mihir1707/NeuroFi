import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  OverviewReportModel? _overview;
  MonthlyReportModel? _monthlyReport;
  YearlyReportModel? _yearlyReport;
  bool _isLoading = false;
  String? _errorMessage;

  OverviewReportModel? get overview => _overview;
  MonthlyReportModel? get monthlyReport => _monthlyReport;
  YearlyReportModel? get yearlyReport => _yearlyReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadOverview() async {
    _setLoading(true);
    _setError(null);
    try {
      _overview = await _reportService.getOverview();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMonthlyReport({required int year, required int month}) async {
    _setLoading(true);
    _setError(null);
    try {
      _monthlyReport = await _reportService.getMonthlyReport(
        year:  year,
        month: month,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentMonthReport() async {
    final now = DateTime.now();
    await loadMonthlyReport(year: now.year, month: now.month);
  }

  Future<void> loadYearlyReport({required int year}) async {
    _setLoading(true);
    _setError(null);
    try {
      _yearlyReport = await _reportService.getYearlyReport(year: year);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentYearReport() async {
    await loadYearlyReport(year: DateTime.now().year);
  }

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _setError(null);
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _reportService.getOverview(),
        _reportService.getMonthlyReport(year: now.year, month: now.month),
      ]);
      _overview      = results[0] as OverviewReportModel;
      _monthlyReport = results[1] as MonthlyReportModel;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
