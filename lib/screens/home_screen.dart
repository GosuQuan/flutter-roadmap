import 'package:flutter/material.dart';
import 'doubao_chat_screen.dart';
import 'profile_screen.dart';
import 'pomodoro_screen.dart';
import 'stream_output_screen.dart';
import 'todo_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildAppsGrid() {
    return GridView.count(
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
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, endColor],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildAppsGrid(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: NavigationBar(
          height: 55,
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          elevation: 0,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.apps, size: 28),
              label: '应用',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, size: 28),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
