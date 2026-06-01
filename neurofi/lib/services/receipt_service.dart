import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/receipt_model.dart';

class ReceiptService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> uploadReceipt(String filePath) async {
    final formData = FormData.fromMap({
      'receipt': await MultipartFile.fromFile(
        filePath,
        filename: 'receipt.jpg',
      ),
    });
    final response = await _dio.post(
      '/receipts',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['data'];
  }

  Future<ReceiptModel> getReceiptById(String receiptId) async {
    final response = await _dio.get('/receipts/$receiptId');
    return ReceiptModel.fromJson(response.data['data']);
  }

  Future<void> linkReceiptToTransaction({
    required String receiptId,
    required String transactionId,
  }) async {
    await _dio.patch('/receipts/$receiptId/link', data: {
      'transactionId': transactionId,
    });
  }

  Future<void> deleteReceipt(String receiptId) async {
    await _dio.delete('/receipts/$receiptId');
  }
}
