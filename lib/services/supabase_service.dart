import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/task_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // AUTH
  Future<AuthResponse> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  User? get currentUser => _client.auth.currentUser;


  Future<List<Task>> fetchTasks() async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> createTask(String title, String? description) async {
    final data = await _client.from('tasks').insert({
      'user_id': currentUser!.id,
      'title': title,
      'description': description,
      'is_completed': false,
    }).select().single();
    return Task.fromJson(data);
  }

  Future<void> deleteTask(String taskId) =>
      _client.from('tasks').delete().eq('id', taskId);

  Future<Task> toggleTask(String taskId, bool isCompleted) async {
    final data = await _client
        .from('tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId)
        .select()
        .single();
    return Task.fromJson(data);
  }

  Future<Task> updateTask(String taskId, String title, String? description) async {
    final data = await _client
        .from('tasks')
        .update({'title': title, 'description': description})
        .eq('id', taskId)
        .select()
        .single();
    return Task.fromJson(data);
  }
}