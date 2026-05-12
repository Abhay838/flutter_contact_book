import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../controllers/contact_controller.dart';

enum ContactStatus { initial, loading, success, error }

class ContactProvider extends ChangeNotifier {
  final ContactController _controller;

  ContactProvider({ContactController? controller})
    : _controller = controller ?? ContactController();

  ContactStatus _status = ContactStatus.initial;
  List<Contact> _contacts = [];
  List<Contact> _favorites = [];
  List<Contact> _searchResults = [];
  String? _errorMessage;
  bool _isSearching = false;
  String _searchQuery = '';

  ///getter

  ContactStatus get status => _status;
  List<Contact> get contacts => _contacts;
  List<Contact> get favorites => _favorites;
  List<Contact> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  bool get isLoading => _status == ContactStatus.loading;

  List<Contact> get displayedContacts =>
      _isSearching ? _searchResults : _contacts;

  Map<String, List<Contact>> get groupedContacts =>
      _controller.groupByAlphabet(displayedContacts);

  ///initial

  Future<void> loadContacts() async {
    _setStatus(ContactStatus.loading);
    try {
      _contacts = await _controller.fetchAllContacts();
      _favorites = await _controller.fetchFavorites();
      _setStatus(ContactStatus.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  ///
  void startSearch() {
    _isSearching = true;
    _searchQuery = '';
    _searchResults = List.from(_contacts);
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = List.from(_contacts);
    } else {
      _searchResults = await _controller.searchContacts(query);
    }
    notifyListeners();
  }

  ///CRUD FOR CONTACT

  Future<Contact?> addContact({
    required String name,
    required String phone,
    String email = '',
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
  }) async {
    try {
      final contact = await _controller.addContact(
        name: name,
        phone: phone,
        email: email,
        address: address,
        company: company,
        notes: notes,
        avatarPath: avatarPath,
      );
      await _refreshLists();
      return contact;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<Contact?> updateContact({
    required Contact contact,
    required String name,
    required String phone,
    String email = '',
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
  }) async {
    try {
      final updated = await _controller.updateContact(
        contact: contact,
        name: name,
        phone: phone,
        email: email,
        address: address,
        company: company,
        notes: notes,
        avatarPath: avatarPath,
      );
      await _refreshLists();
      return updated;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> deleteContact(String id) async {
    try {
      await _controller.deleteContact(id);
      await _refreshLists();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> toggleFavorite(Contact contact) async {
    try {
      final newState = await _controller.toggleFavorite(contact);
      // Optimistic update in memory
      final idx = _contacts.indexWhere((c) => c.id == contact.id);
      if (idx != -1) {
        _contacts[idx] = _contacts[idx].copyWith(isFavorite: newState);
      }
      await _refreshFavorites();
      notifyListeners();
      return newState;
    } catch (e) {
      _setError(e.toString());
      return contact.isFavorite;
    }
  }

  String? validateName(String? value) => _controller.validateNameField(value);
  String? validatePhone(String? value) => _controller.validatePhoneField(value);
  String? validateEmail(String? value) => _controller.validateEmailField(value);

  Future<void> _refreshLists() async {
    _contacts = await _controller.fetchAllContacts();
    _favorites = await _controller.fetchFavorites();
    if (_isSearching) {
      _searchResults = await _controller.searchContacts(_searchQuery);
    }
    notifyListeners();
  }

  Future<void> _refreshFavorites() async {
    _favorites = await _controller.fetchFavorites();
  }

  void _setStatus(ContactStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ContactStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
