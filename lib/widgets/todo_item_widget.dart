import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../styles/todo_styles.dart';
import '../screens/detail_screen.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todo_${item.title}'),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(TodoStyles.borderRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(title: item.title),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: TodoStyles.containerDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: IconButton(
              icon: Icon(
                item.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: item.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: onToggle,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                color: item.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
