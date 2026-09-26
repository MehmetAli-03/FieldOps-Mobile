import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final dynamic taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  bool _isSubmitting = false;

  /// Task State Machine geçişlerini yöneten backend isteği[cite: 2, 3]
  /// Action değerleri: 'accept', 'start', 'complete', 'cancel'[cite: 3]
  Future<void> _changeTaskStatus(String action) async {
    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);

      // PUT /api/tasks/{id}/accept | /start | /complete[cite: 3]
      await dio.put('${ApiEndpoints.tasks}/${widget.taskId}/$action');

      // Provider'ları invalid ederek UI'ın en güncel veriyle çizilmesini sağlıyoruz
      ref.invalidate(taskListProvider);
      ref.invalidate(taskDetailProvider(widget.taskId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev durumu güncellendi ($action).'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayı #${widget.taskId}'),
      ),
      body: taskAsync.when(
        data: (task) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Chip(
                    label: Text('Durum: ${task.status}'),
                    backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Öncelik: ${task.priority}'),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Açıklama:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                task.description.isEmpty ? 'Açıklama bulunmuyor.' : task.description,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const Spacer(),

              // --- STATE MACHINE AKSİYON BUTONLARI ---[cite: 3]
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                _buildActionButton(task.status),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Görev detay bilgisi alınamadı: $err'),
        ),
      ),
    );
  }

  /// Task Status geçişlerine göre görünür buton mantığı[cite: 3]
  Widget _buildActionButton(String status) {
    switch (status) {
      case 'Assigned':
      case '1':
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => _changeTaskStatus('accept'),
            child: const Text('Görevi Kabul Et', style: TextStyle(color: Colors.white)),
          ),
        );
      case 'Accepted':
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => _changeTaskStatus('start'),
            child: const Text('Görevi Başlat', style: TextStyle(color: Colors.white)),
          ),
        );
      case 'InProgress':
      case '2':
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _changeTaskStatus('complete'),
            child: const Text('Görevi Tamamla', style: TextStyle(color: Colors.white)),
          ),
        );
      case 'Completed':
      case '3':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '✓ Bu görev tamamlanmıştır.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'InProgress':
      case '2':
        return Colors.orange;
      case 'Completed':
      case '3':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}