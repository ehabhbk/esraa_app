import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/motivational_messages.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  late String _quote;
  int _day = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _quote = MotivationalMessages.getMessageForDay(_day).text;
  }

  void _refreshQuote() {
    setState(() {
      _quote = MotivationalMessages.getRandom().text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      backgroundColor: isDark
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.purpleSoft,
      child: Column(
        children: [
          Row(
            children: [
              const Text('💫', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'اقتباس اليوم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _refreshQuote,
                child: Icon(
                  Icons.refresh,
                  size: 20,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$_quote"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
        ],
      ),
    );
  }
}
