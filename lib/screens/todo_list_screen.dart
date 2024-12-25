import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../styles/todo_styles.dart';
import '../widgets/todo_item_widget.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todoItems = <TodoItem>[];
  final TextEditingController _controller = TextEditingController();

  void _addTodoItem(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItem(title: title));
        _controller.clear();
      });
    }
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(TodoStyles.defaultPadding),
      decoration: TodoStyles.containerDecoration,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: TodoStyles.inputDecoration,
              onSubmitted: _addTodoItem,
            ),
          ),
          const SizedBox(width: TodoStyles.defaultPadding),
          Container(
            decoration: TodoStyles.buttonDecoration,
            child: ElevatedButton(
              onPressed: () => _addTodoItem(_controller.text),
              style: TodoStyles.addButtonStyle,
              child: const Text(
                '添加',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(TodoStyles.defaultPadding),
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          return TodoItemWidget(
            item: _todoItems[index],
            onToggle: () => _toggleTodoItem(index),
            onDelete: () => _removeTodoItem(index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '我的待办事项',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildInputSection(),
          _buildTodoList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
