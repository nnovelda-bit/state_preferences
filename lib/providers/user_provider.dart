
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    name: '',
    email: '',
    isLoggedIn: false,
  );

  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  // Memuat data dari SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _user = User(
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      isLoggedIn: prefs.getBool('is_logged_in') ?? false,
    );

    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    _visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', _visitCount);

    _favorites = prefs.getStringList('favorites') ?? [];

    _isLoading = false;
    notifyListeners();
  }

  // Menyimpan profil
  Future<void> saveProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();

    _user = User(
      name: name,
      email: email,
      isLoggedIn: true,
    );

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setBool('is_logged_in', true);

    notifyListeners();
  }

  // Mengubah Dark Mode
  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = value;
    await prefs.setBool('is_dark_mode', value);

    notifyListeners();
  }

  // Menambahkan favorit
  Future<void> addFavorite(String item) async {
    if (item.trim().isEmpty) return;

    if (_favorites.contains(item.trim())) return;

    _favorites.add(item.trim());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);

    notifyListeners();
  }

  // Menghapus favorit
  Future<void> removeFavorite(String item) async {
    _favorites.remove(item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);

    notifyListeners();
  }

  // Validasi keamanan Latihan 5
  Future<String?> validateProfile(
    String name,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (RegExp(
      r'<[^>]*>|javascript:',
      caseSensitive: false,
    ).hasMatch(cleanName)) {
      return 'Nama mengandung karakter berbahaya';
    }

    if (!RegExp(
      r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(cleanEmail)) {
      return 'Format email tidak valid';
    }

    final savedEmail = prefs.getString('user_email');

    if (savedEmail != null &&
        savedEmail.isNotEmpty &&
        savedEmail != _user.email &&
        savedEmail == cleanEmail) {
      return 'Email sudah digunakan';
    }

    return null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _user = User(
      name: '',
      email: '',
      isLoggedIn: false,
    );

    await prefs.setBool('is_logged_in', false);

    notifyListeners();
  }
}
