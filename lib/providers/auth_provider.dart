import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';  // ← use AuthService now

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();  // ← use AuthService
  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  bool get isLoggedIn => _service.isLoggedIn;
  User? get currentUser => _service.currentUser;
  String? get currentUserEmail => _service.currentUserEmail;

  Future<bool> signUp(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.signUp(email: email, password: password);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.signIn(email: email, password: password);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    status = AuthStatus.idle;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendPasswordRecovery(String email) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.sendPasswordRecovery(email);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
}