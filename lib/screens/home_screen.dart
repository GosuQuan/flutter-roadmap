import 'package:flutter/material.dart';
import 'todo_list_screen.dart';
import 'pomodoro_screen.dart';
import 'stream_output_screen.dart';
import 'doubao_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildNavigationCard({
    required String title,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          boxShadow: [
            BoxShadow(
              color: endColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
          '我的应用',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildNavigationCard(
            title: '豆包AI',
            icon: Icons.chat,
            startColor: Colors.orange.shade300,
            endColor: Colors.orange.shade600,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoubaoScreen()),
            ),
          ),
          _buildNavigationCard(
            title: '番茄钟',
            icon: Icons.timer,
            startColor: Colors.blue.shade300,
            endColor: Colors.blue.shade600,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PomodoroScreen()),
            ),
          ),
          _buildNavigationCard(
            title: '待办事项',
            icon: Icons.check_circle_outline,
            startColor: Colors.green.shade300,
            endColor: Colors.green.shade600,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TodoListScreen()),
            ),
          ),
          _buildNavigationCard(
            title: '流式输出',
            icon: Icons.stream,
            startColor: Colors.purple.shade300,
            endColor: Colors.purple.shade600,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StreamOutputScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
