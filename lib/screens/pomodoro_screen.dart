import 'dart:async';
import 'package:flutter/material.dart';
import '../styles/todo_styles.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  int _selectedMinutes = 25; // 默认25分钟
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _isRunning ? null : () {
              if (_selectedMinutes > 1) {
                setState(() {
                  _selectedMinutes--;
                  _remainingSeconds = _selectedMinutes * 60;
                });
              }
            },
          ),
          Text(
            '$_selectedMinutes 分钟',
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _isRunning ? null : () {
              setState(() {
                _selectedMinutes++;
                _remainingSeconds = _selectedMinutes * 60;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 50,
            color: Colors.blue,
          ),
          onPressed: _isRunning ? _pauseTimer : _startTimer,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(
            Icons.refresh,
            size: 50,
            color: Colors.blue,
          ),
          onPressed: _resetTimer,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '番茄钟',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeSelector(),
          const SizedBox(height: 40),
          _buildTimer(),
          const SizedBox(height: 40),
          _buildControls(),
        ],
      ),
    );
  }
}
