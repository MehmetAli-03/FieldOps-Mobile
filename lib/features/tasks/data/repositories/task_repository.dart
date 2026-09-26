import 'package:dio/dio.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Dio _dio;

  TaskRepository(this._dio);

  // Tüm görevleri getir
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get('/Tasks');

      final dynamic rawData = response.data;
      List<dynamic> listData = [];

      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
        listData = rawData['data'] as List;
      }

      return listData
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Id ile tek görev getir
  Future<TaskModel> getTaskById(int id) async {
    try {
      final response = await _dio.get('/Tasks/$id');
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Yeni görev ekle
  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      await _dio.post('/Tasks', data: taskData);
    } catch (e) {
      rethrow;
    }
  }
}