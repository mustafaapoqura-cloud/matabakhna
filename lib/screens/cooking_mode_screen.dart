import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  final Set<int> _completedSteps = {};

  // Kitchen Timer State
  Timer? _timer;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    // Default timer to recipe cook time
    _timerSeconds = widget.recipe.cookTimeMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerSeconds <= 0) return;
    setState(() => _isTimerRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _showTimerFinishedAlert();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _timerSeconds = widget.recipe.cookTimeMinutes * 60;
    });
  }

  void _addMinutes(int mins) {
    setState(() {
      _timerSeconds += mins * 60;
    });
  }

  void _showTimerFinishedAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.alarm_on_rounded, color: AppTheme.primary, size: 28),
            SizedBox(width: 8),
            Text('انتهى وقت الطبخ! 🔔'),
          ],
        ),
        content: const Text(
          'انتهى الوقت المحدد على المؤقت، تفقدي وجبتك الشهية وبالهنا والشفا!',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تمام'),
          ),
        ],
      ),
    );
  }

  void _checkCompleteAll() {
    if (_completedSteps.length == widget.recipe.steps.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text('🎉 تسلم إيدك يا شيف!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أتممتِ كل خطوات تحضير الطبق بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'ألف هنا وشفا على قلبك وقلب أسرتك ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('العودة للرئيسية'),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final stepsCount = widget.recipe.steps.length;
    final currentStepText = widget.recipe.steps[_currentStep];
    final isDone = _completedSteps.contains(_currentStep);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24), // Dark kitchen friendly mode
      appBar: AppBar(
        backgroundColor: const Color(0xFF141517),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'وضع الطبخ: ${widget.recipe.name}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer Bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppTheme.secondary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    _formatTimer(_timerSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isTimerRunning ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: AppTheme.primary,
                      size: 38,
                    ),
                  ),
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay_rounded, color: Colors.white70, size: 24),
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.add_alarm_rounded, color: Colors.white70),
                    onSelected: (mins) => _addMinutes(mins),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 1, child: Text('+ دقيقة واحدة')),
                      const PopupMenuItem(value: 5, child: Text('+ 5 دقائق')),
                      const PopupMenuItem(value: 10, child: Text('+ 10 دقائق')),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الخطوة ${_currentStep + 1} من $stepsCount',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'المكتمل: ${_completedSteps.length} / $stepsCount',
                    style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / stepsCount,
                backgroundColor: Colors.white12,
                color: AppTheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Step Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2D35),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isDone ? AppTheme.success : AppTheme.primary,
                          child: Icon(
                            isDone ? Icons.check : Icons.local_dining_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'خطوة رقم ${_currentStep + 1}',
                          style: TextStyle(
                            color: isDone ? Colors.green.shade300 : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          currentStepText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (isDone) {
                            _completedSteps.remove(_currentStep);
                          } else {
                            _completedSteps.add(_currentStep);
                          }
                        });
                        _checkCompleteAll();
                      },
                      icon: Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      ),
                      label: Text(
                        isDone ? 'تم تنفيذ هذه الخطوة ✓' : 'تحديد كمنجزة والانتقال',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? AppTheme.success : AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Step Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    label: const Text('السابقة', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _currentStep < stepsCount - 1
                        ? () => setState(() => _currentStep++)
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    label: const Text('التالية', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
