class AdhkarItem {
  final String text;
  final int repeatCount;
  final String? reference;
  final String category;

  AdhkarItem({required this.text, required this.repeatCount, this.reference, required this.category});
}

class AdhkarData {
  static final List<AdhkarItem> morning = [
    AdhkarItem(text: 'أصبحنا وأصبح الملك لله', repeatCount: 1, reference: 'مسلم', category: 'صباح'),
    AdhkarItem(text: 'اللهم بك أصبحنا وبك أمسينا', repeatCount: 1, reference: 'البخاري', category: 'صباح'),
    AdhkarItem(text: 'اللهم أنت ربي لا إله إلا أنت', repeatCount: 1, reference: 'أبو داود', category: 'صباح'),
    AdhkarItem(text: 'اللهم إني أسألك العافية في الدنيا والآخرة', repeatCount: 3, category: 'صباح'),
    AdhkarItem(text: 'حسبي الله لا إله إلا هو عليه توكلت', repeatCount: 7, reference: 'التوبة ١٢٩', category: 'صباح'),
    AdhkarItem(text: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء', repeatCount: 3, reference: 'أبو داود', category: 'صباح'),
  ];
  static final List<AdhkarItem> evening = [
    AdhkarItem(text: 'أمسينا وأمسى الملك لله', repeatCount: 1, reference: 'مسلم', category: 'مساء'),
    AdhkarItem(text: 'اللهم بك أمسينا وبك أصبحنا', repeatCount: 1, reference: 'البخاري', category: 'مساء'),
    AdhkarItem(text: 'اللهم أنت ربي لا إله إلا أنت', repeatCount: 1, reference: 'أبو داود', category: 'مساء'),
    AdhkarItem(text: 'أعوذ بكلمات الله التامات من شر ما خلق', repeatCount: 3, reference: 'مسلم', category: 'مساء'),
    AdhkarItem(text: 'اللهم صل وسلم على نبينا محمد', repeatCount: 10, category: 'مساء'),
  ];
  static final List<AdhkarItem> general = [
    AdhkarItem(text: 'سبحان الله وبحمده', repeatCount: 100, category: 'عام'),
    AdhkarItem(text: 'أستغفر الله', repeatCount: 100, category: 'عام'),
    AdhkarItem(text: 'لا إله إلا الله', repeatCount: 100, category: 'عام'),
  ];
}
