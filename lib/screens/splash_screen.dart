import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              Color(0xFF8B83FF),
              Color(0xFFA29BFE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                '🌸',
                style: TextStyle(fontSize: 64),
              ).animate().fadeIn(duration: 800.ms).scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1)),
              const SizedBox(height: 20),
              const Text(
                'السلام عليكم يا دكتورة إسراء 🌷',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ).animate().fadeIn(
                duration: 600.ms,
                delay: 400.ms,
              ).slideY(begin: 0.3),
              const SizedBox(height: 16),
              const Text(
                'اليوم فرصة جديدة لتتركي أثرًا جميلًا في حياة المرضى.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(
                duration: 600.ms,
                delay: 800.ms,
              ).slideY(begin: 0.3),
              const SizedBox(height: 40),
              const Text(
                'Esraa ❤️',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(
                duration: 600.ms,
                delay: 1200.ms,
              ).slideY(begin: 0.3),
              const Spacer(),
              const Text(
                'v1.0',
                style: TextStyle(color: Colors.white38),
              ).animate().fadeIn(delay: 2000.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
