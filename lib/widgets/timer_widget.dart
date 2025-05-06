import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';

class TimerWidget extends StatefulWidget {
  final int minutes;
  
  const TimerWidget({
    Key? key,
    required this.minutes,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  final List<int> _alertAtSeconds = [0, 10, 30, 60];
  
  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _remainingSeconds = _totalSeconds;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    if (_isRunning || _isCompleted) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        _handleTimerComplete();
        return;
      }
      
      setState(() {
        _remainingSeconds--;
      });
      
      if (_alertAtSeconds.contains(_remainingSeconds)) {
        _playAlertSound();
      }
    });
  }
  
  void _pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    
    setState(() {
      _isRunning = false;
    });
  }
  
  void _resetTimer() {
    _timer?.cancel();
    
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _remainingSeconds = _totalSeconds;
    });
  }
  
  void _handleTimerComplete() {
    _timer?.cancel();
    
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    
    _playAlertSound();
    _showCompletionNotification();
  }
  
  void _playAlertSound() {
    HapticFeedback.vibrate();
    // In a real app, you would also play a sound here
  }
  
  void _showCompletionNotification() {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Timer Complete!'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / _totalSeconds;
    final textColor = _isCompleted
        ? Colors.green
        : _remainingSeconds < 60
            ? Colors.red
            : null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Timer: ${widget.minutes} ${widget.minutes == 1 ? 'minute' : 'minutes'}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isCompleted
                        ? Colors.green
                        : _remainingSeconds < 60
                            ? Colors.red
                            : AppTheme.primaryColor,
                  ),
                  strokeWidth: 8,
                ),
              ),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isCompleted) ...[
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: _isRunning ? Colors.orange : AppTheme.primaryColor,
                  ),
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Reset'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
