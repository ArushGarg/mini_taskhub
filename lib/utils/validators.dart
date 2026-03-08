extension StringValidators on String {
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  bool get isValidPassword => length >= 6;

  bool get isNotBlank => trim().isNotEmpty;
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.isValidEmail) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!value.isValidPassword) return 'Password must be at least 6 characters';
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Task title cannot be empty';
    if (value.length > 100) return 'Title too long (max 100 chars)';
    return null;
  }
}