import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/report_model.dart';

class ReportService {
  final Dio _dio = DioClient.instance;

  Future<OverviewReportModel> getOverview() async {
    final response = await _dio.get('/reports/overview');
    return OverviewReportModel.fromJson(response.data['data']);
  }

  Future<MonthlyReportModel> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final response = await _dio.get('/reports/monthly', queryParameters: {
      'year':  year,
      'month': month,
    });
    return MonthlyReportModel.fromJson(response.data['data']);
  }

  Future<MonthlyReportModel> getCurrentMonthReport() async {
    final now = DateTime.now();
    return getMonthlyReport(year: now.year, month: now.month);
  }

  Future<YearlyReportModel> getYearlyReport({required int year}) async {
    final response = await _dio.get('/reports/yearly', queryParameters: {
      'year': year,
    });
    return YearlyReportModel.fromJson(response.data['data']);
  }

  Future<YearlyReportModel> getCurrentYearReport() async {
    return getYearlyReport(year: DateTime.now().year);
  }

  Future<Map<String, dynamic>> getCurrencyRates({String baseCurrency = 'INR'}) async {
    final response = await _dio.get('/reports/currency', queryParameters: {
      'base': baseCurrency,
    });
    return response.data['data'];
  }

  Future<String> exportCsv({String? startDate, String? endDate, String? type}) async {
    final response = await _dio.get(
      '/reports/export',
      queryParameters: {
        'startDate': ?startDate,
        'endDate':   ?endDate,
        'type':       ?type,
      },
      options: Options(responseType: ResponseType.plain),
    );
    return response.data.toString();
  }
}
