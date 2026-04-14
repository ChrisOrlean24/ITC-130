import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<TodoItem> _todos = [
    TodoItem(id: '1', title: 'Buy groceries'),
    TodoItem(id: '2', title: 'Read a book'),
    TodoItem(id: '3', title: 'Go for a walk'),
  ];

  final TextEditingController _controller = TextEditingController();
  String _filter = 'All'; // All, Active, Completed

  List<TodoItem> get _filteredTodos {
    switch (_filter) {
      case 'Active':
        return _todos.where((t) => !t.isCompleted).toList();
      case 'Completed':
        return _todos.where((t) => t.isCompleted).toList();
      default:
        return _todos;
    }
  }

  int get _activeCount => _todos.where((t) => !t.isCompleted).length;

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text,
      ));
      _controller.clear();
    });
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.isCompleted = !todo.isCompleted;
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }

  void _clearCompleted() {
    setState(() {
      _todos.removeWhere((t) => t.isCompleted);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [purple, const Color(0xFF9B97F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 My Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_activeCount task${_activeCount != 1 ? 's' : ''} remaining',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input field
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _addTodo(),
                            decoration: const InputDecoration(
                              hintText: 'Add a new task...',
                              hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _addTodo,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add_rounded, color: purple, size: 26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: ['All', 'Active', 'Completed'].map((filter) {
                  final isSelected = _filter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? purple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: purple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Todo list
            Expanded(
              child: _filteredTodos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'Completed'
                                ? 'No completed tasks yet'
                                : 'No tasks here!',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: _filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = _filteredTodos[index];
                        return _TodoCard(
                          todo: todo,
                          onToggle: () => _toggleTodo(todo.id),
                          onDelete: () => _deleteTodo(todo.id),
                          accentColor: purple,
                        );
                      },
                    ),
            ),

            // Footer
            if (_todos.any((t) => t.isCompleted))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextButton.icon(
                  onPressed: _clearCompleted,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear completed'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color accentColor;

  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: todo.isCompleted ? accentColor : Colors.transparent,
                border: Border.all(
                  color: todo.isCompleted ? accentColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: todo.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 15,
              color: todo.isCompleted ? Colors.grey[400] : Colors.grey[800],
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontWeight:
                  todo.isCompleted ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.grey[300], size: 20),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}