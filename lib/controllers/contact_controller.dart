import '../models/contact_model.dart';
import '../services/database_service.dart';

class ContactController {
  final DatabaseService _db;

  ContactController({DatabaseService? dbService})
    : _db = dbService ?? DatabaseService();

  ///read
  Future<List<Contact>> fetchAllContacts() => _db.getAllContacts();

  Future<List<Contact>> fetchFavorites() => _db.getFavoriteContacts();

  Future<List<Contact>> searchContacts(String query) {
    if (query.trim().isEmpty) return fetchAllContacts();
    return _db.searchContacts(query.trim());
  }

  Future<Contact?> fetchContactById(String id) => _db.getContactById(id);

  //edit

  Future<Contact> addContact({
    required String name,
    required String phone,
    String email = '',
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
  }) async {
    _validateName(name);
    _validatePhone(phone);

    final contact = Contact(
      id: _generateId(),
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address?.trim(),
      company: company?.trim(),
      notes: notes?.trim(),
      avatarPath: avatarPath,
    );

    await _db.insertContact(contact);
    return contact;
  }

  Future<Contact> updateContact({
    required Contact contact,
    required String name,
    required String phone,
    String email = '',
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
  }) async {
    _validateName(name);
    _validatePhone(phone);

    final updated = contact.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address?.trim(),
      company: company?.trim(),
      notes: notes?.trim(),
      avatarPath: avatarPath,
      updatedAt: DateTime.now(),
    );

    await _db.updateContact(updated);
    return updated;
  }

  Future<void> deleteContact(String id) async {
    await _db.deleteContact(id);
  }

  Future<bool> toggleFavorite(Contact contact) async {
    final newState = !contact.isFavorite;
    await _db.toggleFavorite(contact.id, newState);
    return newState;
  }

  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Contact name cannot be empty.');
    }
    if (name.trim().length < 2) {
      throw ArgumentError('Name must be at least 2 characters.');
    }
  }

  void _validatePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 7) {
      throw ArgumentError('Please enter a valid phone number.');
    }
  }

  String? validateNameField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePhoneField(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 7) return 'Enter a valid phone number';
    return null;
  }

  String? validateEmailField(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  Map<String, List<Contact>> groupByAlphabet(List<Contact> contacts) {
    final Map<String, List<Contact>> grouped = {};
    for (final c in contacts) {
      final key = c.groupKey;
      grouped.putIfAbsent(key, () => []).add(c);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${1000 + (DateTime.now().microsecond % 9000)}';
}
