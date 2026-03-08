import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final _service = SupabaseService();
  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  bool get isLoggedIn => _service.currentUser != null;
  User? get currentUser => _service.currentUser;

  Future<bool> signUp(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.signUp(email, password);
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
      await _service.signIn(email, password);
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
    notifyListeners();
  }
}