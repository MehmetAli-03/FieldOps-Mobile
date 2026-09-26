class TaskModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      priority: json['priority']?.toString() ?? '0',
      assignedTo: json['assignedTo']?.toString(),
    );
  }
}