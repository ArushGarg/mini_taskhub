import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Get the Supabase client instance
  final _client = Supabase.instance.client;



  User? get currentUser => _client.auth.currentUser;


  Session? get currentSession => _client.auth.currentSession;


  bool get isLoggedIn => currentUser != null;


  String? get currentUserEmail => currentUser?.email;

  String? get currentUserId => currentUser?.id;



  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }


  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }


  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;



  // Send password reset email
  Future<void> sendPasswordRecovery(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Password recovery failed: $e');
    }
  }

  // Update password (after recovery)
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }
}