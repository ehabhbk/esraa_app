import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({super.key});

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isRunning = false;
  int _cycleCount = 0;
  Timer? _phaseTimer;
  String _currentPhase = 'شهيق';
  int _secondsLeft = 4;

  final phases = [
    {'label': 'شهيق', 'duration': 4},
    {'label': 'احتفظ', 'duration': 4},
    {'label': 'زفير', 'duration': 4},
  ];
  int _phaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed && _isRunning) {
        _controller.forward();
      }
    });
  }

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _cycleCount = 0;
      _phaseIndex = 0;
      _currentPhase = 'شهيق';
      _secondsLeft = 4;
    });
    _controller.forward();
    _startPhaseTimer();
  }

  void _startPhaseTimer() {
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _phaseIndex = (_phaseIndex + 1) % phases.length;
          _currentPhase = phases[_phaseIndex]['label']! as String;
          _secondsLeft = phases[_phaseIndex]['duration']! as int;
          if (_phaseIndex == 0) {
            _cycleCount++;
          }
          if (_phaseIndex == 1) {
            _controller.stop();
          } else if (_phaseIndex == 2) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        }
      });
    });
  }

  void _stopExercise() {
    _phaseTimer?.cancel();
    _controller.stop();
    _controller.reset();
    setState(() {
      _isRunning = false;
      _currentPhase = 'شهيق';
      _secondsLeft = 4;
      _phaseIndex = 0;
    });
  }

  Color get _phaseColor {
    switch (_currentPhase) {
      case 'شهيق':
        return AppColors.primary;
      case 'احتفظ':
        return AppColors.warning;
      case 'زفير':
        return AppColors.greenSoft;
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseColorVal = _phaseColor;
    return Scaffold(
      appBar: AppBar(title: const Text('🧘 استرخاء')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassCard(
                child: Column(
                  children: [
                    const Text('تمارين التنفس', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('استرخي وركز على تنفسك', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _scaleAnim,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [phaseColorVal.withValues(alpha: 0.6), phaseColorVal.withValues(alpha: 0.1)],
                            ),
                            boxShadow: [
                              BoxShadow(color: phaseColorVal.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5),
                            ],
                          ),
                          child: Transform.scale(
                            scale: _isRunning ? _scaleAnim.value : 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phaseColorVal.withValues(alpha: 0.3),
                                border: Border.all(color: phaseColorVal, width: 3),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_currentPhase, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: phaseColorVal)),
                                    const SizedBox(height: 4),
                                    Text('$_secondsLeft', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: phaseColorVal)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isRunning)
                      Text('الدورة $_cycleCount', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? _stopExercise : _startExercise,
                        icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                        label: Text(_isRunning ? 'إيقاف' : 'ابدأ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? AppColors.error : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
