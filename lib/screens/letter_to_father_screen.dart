import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/letter_to_father.dart';
import '../providers/letters_provider.dart';

class LetterToFatherScreen extends StatefulWidget {
  const LetterToFatherScreen({super.key});

  @override
  State<LetterToFatherScreen> createState() => _LetterToFatherScreenState();
}

class _LetterToFatherScreenState extends State<LetterToFatherScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LettersProvider>().loadLetters();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendLetter() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<LettersProvider>().addLetter(
          LetterToFather(content: text),
        );
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤲 تم إرسال الرسالة'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✉️ إلى أبي')),
      body: Consumer<LettersProvider>(
        builder: (context, lettersProvider, child) {
          final letters = lettersProvider.letters;
          return Column(
            children: [
              GlassCard(
                backgroundColor: AppColors.purpleSoft,
                margin: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    Text('🤲', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'إلى أبي الحبيب إبراهيم مضوي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اللهم اغفر له وارحمه واجعل الجنة مثواه',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'اكتبي رسالتك إلى أبي...',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendLetter(),
                        ),
                      ),
                      IconButton(
                        onPressed: _sendLetter,
                        icon: const Icon(Icons.send_rounded,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              if (letters.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('الرسائل السابقة',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${letters.length} رسالة',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              Expanded(
                child: letters.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('✉️', style: TextStyle(fontSize: 64)),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد رسائل بعد',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'اكتبي أول رسالة إلى أبي',
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: letters.length,
                        itemBuilder: (context, index) {
                          final letter = letters[index];
                          final dateStr = DateFormat('EEEE, MMM d, y', 'ar')
                              .format(letter.createdAt);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🤲', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => lettersProvider
                                            .deleteLetter(letter.id!),
                                        child: const Icon(Icons.delete_outline,
                                            size: 18, color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    letter.content,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
