import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../dashboard/dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;

  late AnimationController _contentController;
  late Animation<double> _logoAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _fieldsAnim;
  late Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoAnim = _stagger(0.0, 0.25);
    _titleAnim = _stagger(0.15, 0.40);
    _fieldsAnim = _stagger(0.30, 0.65);
    _buttonAnim = _stagger(0.55, 0.85);
    _contentController.forward();
  }

  Animation<double> _stagger(double start, double end) {
    return CurvedAnimation(
      parent: _contentController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the Privacy Policy',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok =
    await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131F),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2A2A3E),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Logo
                    _FadeSlide(
                      animation: _logoAnim,
                      child: _DayTaskLogoSmall(),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    _FadeSlide(
                      animation: _titleAnim,
                      child: Column(
                        children: [
                          Text(
                            'Create your account',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start organizing your tasks today',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Full name
                    _FadeSlide(
                      animation: _fieldsAnim,
                      child: _DayTaskTextField(
                        controller: _nameCtrl,
                        hint: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Email
                    _FadeSlide(
                      animation: _fieldsAnim,
                      child: _DayTaskTextField(
                        controller: _emailCtrl,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password
                    _FadeSlide(
                      animation: _fieldsAnim,
                      child: _DayTaskTextField(
                        controller: _passCtrl,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePass,
                        validator: Validators.password,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Confirm password
                    _FadeSlide(
                      animation: _fieldsAnim,
                      child: _DayTaskTextField(
                        controller: _confirmCtrl,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        validator: (v) {
                          if (v != _passCtrl.text)
                            return 'Passwords do not match';
                          return Validators.password(v);
                        },
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Privacy policy checkbox
                    _FadeSlide(
                      animation: _fieldsAnim,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreed,
                              onChanged: (v) =>
                                  setState(() => _agreed = v ?? false),
                              activeColor: const Color(0xFFF5C518),
                              checkColor: const Color(0xFF13131F),
                              side: const BorderSide(
                                  color: Colors.white38, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I have read & agreed to DayTask\'s ',
                                style: GoogleFonts.poppins(
                                    color: Colors.white38, fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFF5C518),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' & ',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Condition',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFF5C518),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        if (auth.errorMessage == null)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                  Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(auth.errorMessage!,
                                      style: GoogleFonts.poppins(
                                          color: Colors.redAccent,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Sign up button
                    _FadeSlide(
                      animation: _buttonAnim,
                      child: Consumer<AuthProvider>(
                        builder: (_, auth, __) => _YellowButton(
                          label: 'Sign Up',
                          onPressed:
                          auth.status == AuthStatus.loading
                              ? null
                              : _signup,
                          isLoading: auth.status == AuthStatus.loading,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    _FadeSlide(
                      animation: _buttonAnim,
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.white12, thickness: 1)),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('Or continue with',
                                style: GoogleFonts.poppins(
                                    color: Colors.white38, fontSize: 12)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.white12, thickness: 1)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Google
                    _FadeSlide(
                      animation: _buttonAnim,
                      child: _GoogleButton(),
                    ),

                    const SizedBox(height: 24),

                    // Login link
                    _FadeSlide(
                      animation: _buttonAnim,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account?  ',
                            style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFF5C518),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTaskLogoSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF2A2A3E),
          ),
          child: const Icon(Icons.wb_sunny_rounded,
              color: Color(0xFFF5C518), size: 22),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Day',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              TextSpan(
                  text: 'Task',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF5C518))),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayTaskTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _DayTaskTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFF5C518), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

class _YellowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  const _YellowButton(
      {required this.label, this.onPressed, required this.isLoading});

  @override
  State<_YellowButton> createState() => _YellowButtonState();
}

class _YellowButtonState extends State<_YellowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.96,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.onPressed == null
                ? Colors.grey.shade700
                : const Color(0xFFF5C518),
            boxShadow: widget.onPressed == null
                ? []
                : [
              BoxShadow(
                color: const Color(0xFFF5C518).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Color(0xFF13131F), strokeWidth: 2.5),
            )
                : Text(
              widget.label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF13131F),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF2A2A3E),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('G',
              style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Text('Continue with Google',
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}