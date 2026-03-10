import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _error;
  bool _isGoogleLoading = false;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGoogleLoading => _isGoogleLoading;

  AuthProvider() {
    _authService.userStream.listen(_onAuthStateChanged);
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _onAuthStateChanged(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      await prefs.setBool('isLoggedIn', false);
    } else {
      _user = user;
      _status = AuthStatus.authenticated;
      await prefs.setBool('isLoggedIn', true);
    }
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      await _authService.signUp(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      await _authService.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _isGoogleLoading = true;
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      final userCred = await _authService.signInWithGoogle();

      // If userCred is null, the user cancelled the flow.
      if (userCred == null) {
        _isGoogleLoading = false;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      _isGoogleLoading = false;
      return true;
    } catch (e) {
      _isGoogleLoading = false;
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    if (_user == null) return null;
    return await _user!.getIdToken();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
