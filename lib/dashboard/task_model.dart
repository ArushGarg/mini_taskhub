class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    isCompleted: json['is_completed'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'is_completed': isCompleted,
    'created_at': createdAt.toIso8601String(),
  };

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
}