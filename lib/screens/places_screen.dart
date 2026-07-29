import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/place_provider.dart';
import '../models/visited_place.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaceProvider>().loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ أماكن زرتها'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('الكل', 0),
                const SizedBox(width: 8),
                _buildFilterChip('المفضلة', 1),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PlaceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final places = _filterIndex == 0 ? provider.places : provider.favorites;
                if (places.isEmpty) {
                  return Center(
                    child: Text(
                      _filterIndex == 0 ? 'لا توجد أماكن بعد 🌸' : 'لا توجد أماكن مفضلة',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return _buildPlaceCard(place, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final selected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(VisitedPlace place, PlaceProvider provider) {
    final emojis = ['🏛️', '🌊', '🏔️', '🏖️', '🌸', '🌳', '🏰', '🕌', '🎡', '🏕️'];
    final emoji = emojis[place.name.hashCode.abs() % emojis.length];
    final dateStr = DateFormat('d MMMM y', 'ar').format(place.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (place.city.isNotEmpty)
                        Text(place.city, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(dateStr, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.toggleFavorite(place.id!),
                  child: Icon(
                    place.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: place.isFavorite ? AppColors.accent : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < place.rating ? Icons.star : Icons.star_border,
                  color: AppColors.gold,
                  size: 20,
                );
              }),
            ),
            if (place.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(place.notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showEditDialog(context, place),
                  child: const Icon(Icons.edit, size: 18, color: AppColors.textLight),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _confirmDelete(context, place.id!),
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    double rating = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة مكان جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المكان', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'المدينة', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'التاريخ', border: OutlineInputBorder()),
                    child: Text(DateFormat('d MMMM y', 'ar').format(selectedDate), textAlign: TextAlign.right),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('التقييم: '),
                    Expanded(
                      child: Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: rating.round().toString(),
                        onChanged: (v) => setDialogState(() => rating = v),
                      ),
                    ),
                    Text('${rating.round()}'),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<PlaceProvider>().addPlace(VisitedPlace(
                  name: nameCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  date: selectedDate,
                  rating: rating.round(),
                  notes: notesCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, VisitedPlace place) {
    final nameCtrl = TextEditingController(text: place.name);
    final cityCtrl = TextEditingController(text: place.city);
    final notesCtrl = TextEditingController(text: place.notes);
    DateTime selectedDate = place.date;
    double rating = place.rating.toDouble();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('تعديل المكان'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المكان', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'المدينة', border: OutlineInputBorder()), textAlign: TextAlign.right),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'التاريخ', border: OutlineInputBorder()),
                    child: Text(DateFormat('d MMMM y', 'ar').format(selectedDate), textAlign: TextAlign.right),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('التقييم: '),
                    Expanded(
                      child: Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: rating.round().toString(),
                        onChanged: (v) => setDialogState(() => rating = v),
                      ),
                    ),
                    Text('${rating.round()}'),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<PlaceProvider>().updatePlace(VisitedPlace(
                  id: place.id,
                  name: nameCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  date: selectedDate,
                  rating: rating.round(),
                  notes: notesCtrl.text.trim(),
                  isFavorite: place.isFavorite,
                  createdAt: place.createdAt,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المكان'),
        content: const Text('هل أنت متأكدة من الحذف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              context.read<PlaceProvider>().deletePlace(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
