import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.userStream.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _user = user;
      _status = AuthStatus.authenticated;
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
