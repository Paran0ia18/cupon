import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore extends ChangeNotifier {
  static const String _loggedInKey = 'kurukshetra_logged_in';
  static const String _phoneKey = 'kurukshetra_phone';

  bool _isLoggedIn = false;
  String _phone = '';
  String _pendingOtp = '0000';
  String _pendingPhone = '';

  bool get isLoggedIn => _isLoggedIn;
  String get phone => _phone;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    _phone = prefs.getString(_phoneKey) ?? '';
    notifyListeners();
  }

  Future<String> requestOtp(String rawPhone) async {
    final normalized = _normalizePhone(rawPhone);
    _pendingPhone = normalized;
    _pendingOtp = _randomOtp();
    return _pendingOtp;
  }

  Future<bool> verifyOtp(String otp) async {
    final trimmed = otp.trim();
    if (trimmed != _pendingOtp) {
      return false;
    }

    _isLoggedIn = true;
    _phone = _pendingPhone;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_phoneKey, _phone);

    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _phone = '';
    _pendingPhone = '';
    _pendingOtp = '0000';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_phoneKey);
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    return digits.isEmpty ? raw.trim() : digits;
  }

  String _randomOtp() {
    final random = Random();
    final value = random.nextInt(9000) + 1000;
    return value.toString();
  }
}
