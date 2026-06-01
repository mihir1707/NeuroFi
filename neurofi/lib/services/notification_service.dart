import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioClient.instance;

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/notifications', queryParameters: {
      'page':  page,
      'limit': limit,
      if (isRead != null) 'isRead': isRead,
    });
    final List data = response.data['data'];
    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete('/notifications/$notificationId');
  }

  Future<int> getUnreadCount() async {
    final notifications = await getUnreadNotifications();
    return notifications.length;
  }
}
