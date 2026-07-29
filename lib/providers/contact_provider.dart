import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/database_service.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  Future<void> loadContacts() async {
    final data = await DatabaseService.query('contacts', orderBy: 'createdAt DESC');
    _contacts = data.map((m) => Contact.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addContact(Contact c) async {
    await DatabaseService.insert('contacts', c.toMap());
    await loadContacts();
  }

  Future<void> deleteContact(int id) async {
    await DatabaseService.delete('contacts', 'id = ?', [id]);
    await loadContacts();
  }
}
