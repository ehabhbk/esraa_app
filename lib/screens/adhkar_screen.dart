import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../data/adhkar_data.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AdhkarItem> _getList(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AdhkarData.morning;
      case 1:
        return AdhkarData.evening;
      case 2:
        return AdhkarData.general;
      default:
        return [];
    }
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return '🌅 صباح';
      case 1:
        return '🌇 مساء';
      case 2:
        return '📿 عام';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌙 أذكار الصباح والمساء'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: _getTabTitle(0)),
            Tab(text: _getTabTitle(1)),
            Tab(text: _getTabTitle(2)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (tabIndex) {
          final items = _getList(tabIndex);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final globalIndex = tabIndex * 100 + index;
              final item = items[index];
              final count = _counts[globalIndex] ?? 0;
              final isComplete = count >= item.repeatCount;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.8,
                              ),
                            ),
                          ),
                          if (isComplete)
                            const Text('✅', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      if (item.reference != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.reference!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.purpleSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.repeatCount} مرة',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (!isComplete) {
                                setState(() {
                                  _counts[globalIndex] = (count + 1);
                                });
                              }
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isComplete ? AppColors.greenSoft : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  isComplete ? '✓' : '${item.repeatCount - count}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isComplete ? 20 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isComplete && count > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: count / item.repeatCount,
                            minHeight: 6,
                            backgroundColor: AppColors.greenSoft,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
