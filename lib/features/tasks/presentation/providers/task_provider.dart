import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/task_model.dart';

// Tüm Görevleri Listeleyen Provider
final taskListProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.tasks);

  final rawData = response.data;

  // 1. Durum: Backend direkt Liste dönüyorsa [ {...}, {...} ]
  if (rawData is List) {
    return rawData
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 2. Durum: Backend { "success": true, "data": [...] } sarmalı ile dönüyorsa
  if (rawData is Map<String, dynamic>) {
    if (rawData['success'] == true && rawData['data'] != null) {
      final data = rawData['data'];
      if (data is List) {
        return data
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        final List items = data['items'];
        return items
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }

  return [];
});

// ID Tabanlı Tekil Görev Detayı Sağlayan Provider
final taskDetailProvider = FutureProvider.autoDispose.family<TaskModel, dynamic>((ref, taskId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiEndpoints.tasks}/$taskId');

  final rawData = response.data;

  if (rawData is Map<String, dynamic>) {
    if (rawData.containsKey('data') && rawData['data'] != null) {
      return TaskModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }
    return TaskModel.fromJson(rawData);
  }

  throw Exception('Görev detay verisi okunamadı.');
});