import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
    });
  }

  void _showDialog() {
    final nameCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة جهة اتصال'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()), textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: specialtyCtrl, decoration: const InputDecoration(labelText: 'الاختصاص', border: OutlineInputBorder()), textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()), keyboardType: TextInputType.phone, textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: hospitalCtrl, decoration: const InputDecoration(labelText: 'المستشفى', border: OutlineInputBorder()), textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3, textAlign: TextAlign.right),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || specialtyCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              final c = Contact(
                name: nameCtrl.text,
                specialty: specialtyCtrl.text,
                phone: phoneCtrl.text,
                hospital: hospitalCtrl.text,
                notes: notesCtrl.text,
              );
              context.read<ContactProvider>().addContact(c);
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📞 جهات الاتصال')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          if (provider.contacts.isEmpty) {
            return const Center(
              child: Text('لا توجد جهات اتصال', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.contacts.length,
            itemBuilder: (context, index) {
              final c = provider.contacts[index];
              return Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteContact(c.id!),
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text(c.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(c.specialty, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(c.phone, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse('tel:${c.phone}');
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.phone, color: AppColors.success, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
