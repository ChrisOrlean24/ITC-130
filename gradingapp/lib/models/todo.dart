enum TodoPriority { low, medium, high }

enum TodoStatus { pending, completed }

class Todo {
  final String id;
  final String title;
  final String? description;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime? dueDate;
  final String? category;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.priority = TodoPriority.medium,
    this.status = TodoStatus.pending,
    this.dueDate,
    this.category,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    String? category,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TodoPriority.medium,
      ),
      status: TodoStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TodoStatus.pending,
      ),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      category: map['category'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
