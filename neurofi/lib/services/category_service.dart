import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio _dio = DioClient.instance;

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final response = await _dio.get('/categories', queryParameters: {
      if (type != null) 'type': type,
    });
    final List data = response.data['data'];
    return data.map((item) => CategoryModel.fromJson(item)).toList();
  }

  Future<List<CategoryModel>> getExpenseCategories() async {
    return getCategories(type: 'expense');
  }

  Future<List<CategoryModel>> getIncomeCategories() async {
    return getCategories(type: 'income');
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String type,
    String icon = '📦',
    String color = '#64748B',
  }) async {
    final response = await _dio.post('/categories', data: {
      'name':  name,
      'type':  type,
      'icon':  icon,
      'color': color,
    });
    return CategoryModel.fromJson(response.data['data']);
  }

  Future<CategoryModel> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/categories/$categoryId', data: updates);
    return CategoryModel.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _dio.delete('/categories/$categoryId');
  }
}
