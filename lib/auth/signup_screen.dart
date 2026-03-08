import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../dashboard/dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.task_alt, color: theme.colorScheme.primary, size: 30),
                    ),
                    const SizedBox(height: 24),
                    Text('Create Account 🚀', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Start managing your tasks today', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passCtrl.text) return 'Passwords do not match';
                        return Validators.password(value);
                      },
                    ),
                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        if (auth.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(auth.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => ElevatedButton(
                        onPressed: auth.status == AuthStatus.loading ? null : _signup,
                        child: auth.status == AuthStatus.loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}