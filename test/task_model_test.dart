import 'package:flutter_test/flutter_test.dart';
import 'package:mini_taskhub/dashboard/task_model.dart';

void main() {
  group('Task Model', () {
    final testJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'user_id': 'user-123',
      'title': 'Buy groceries',
      'description': 'Milk, eggs, bread',
      'is_completed': false,
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('fromJson creates Task correctly', () {
      final task = Task.fromJson(testJson);
      expect(task.id, testJson['id']);
      expect(task.title, testJson['title']);
      expect(task.isCompleted, false);
    });

    test('toJson returns correct map', () {
      final task = Task.fromJson(testJson);
      final json = task.toJson();
      expect(json['title'], 'Buy groceries');
      expect(json['is_completed'], false);
    });

    test('copyWith updates fields correctly', () {
      final task = Task.fromJson(testJson);
      final updated = task.copyWith(isCompleted: true, title: 'Done shopping');
      expect(updated.isCompleted, true);
      expect(updated.title, 'Done shopping');
      expect(updated.id, task.id); // unchanged
    });
  });
}