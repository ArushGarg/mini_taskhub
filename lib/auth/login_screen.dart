import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../dashboard/dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late AnimationController _contentCtrl;
  late Animation<double> _logoAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _emailAnim;
  late Animation<double> _passAnim;
  late Animation<double> _buttonAnim;
  late Animation<double> _bottomAnim;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoAnim = _stagger(0.00, 0.22);
    _titleAnim = _stagger(0.12, 0.35);
    _emailAnim = _stagger(0.28, 0.52);
    _passAnim = _stagger(0.38, 0.62);
    _buttonAnim = _stagger(0.52, 0.76);
    _bottomAnim = _stagger(0.66, 0.90);
    _contentCtrl.forward();
  }

  Animation<double> _stagger(double s, double e) => CurvedAnimation(
    parent: _contentCtrl,
    curve: Interval(s, e, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _contentCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C2331),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  _FadeSlide(
                    animation: _logoAnim,
                    child: _DayTaskLogoCenter(),
                  ),

                  const SizedBox(height: 40),

                  // Welcome Back title - LEFT aligned like Figma
                  _FadeSlide(
                    animation: _titleAnim,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email label + field
                  _FadeSlide(
                    animation: _emailAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Email Address'),
                        const SizedBox(height: 8),
                        _DayTaskField(
                          controller: _emailCtrl,
                          hint: 'fazzzil72@gmail.com',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password label + field
                  _FadeSlide(
                    animation: _passAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        _DayTaskField(
                          controller: _passCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          validator: Validators.password,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF8A9BB0),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFF5C518),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error message
                  Consumer<AuthProvider>(builder: (_, auth, __) {
                    if (auth.errorMessage == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ErrorBanner(message: auth.errorMessage!),
                    );
                  }),

                  // Log In button
                  _FadeSlide(
                    animation: _buttonAnim,
                    child: Consumer<AuthProvider>(
                      builder: (_, auth, __) => _YellowButton(
                        label: 'Log In',
                        onPressed:
                        auth.status == AuthStatus.loading ? null : _login,
                        isLoading: auth.status == AuthStatus.loading,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Or continue with divider
                  _FadeSlide(
                    animation: _bottomAnim,
                    child: _OrDivider(),
                  ),

                  const SizedBox(height: 20),

                  // Google button
                  _FadeSlide(
                    animation: _bottomAnim,
                    child: _GoogleButton(),
                  ),

                  const SizedBox(height: 28),

                  // Sign up link
                  _FadeSlide(
                    animation: _bottomAnim,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account?  ",
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF8A9BB0), fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

class _DayTaskLogoCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF5C518),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF5C518).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.timer_outlined,
              color: Color(0xFF1C2331), size: 32),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Day',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Task',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF5C518),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.poppins(
      color: const Color(0xFF8A9BB0),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _DayTaskField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _DayTaskField({
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
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF8A9BB0),
          fontSize: 14,
        ),
        prefixIcon:
        Icon(icon, color: const Color(0xFF8A9BB0), size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF263040),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFF5C518), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.redAccent.withOpacity(0.7)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(
            color: Colors.redAccent, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 18),
      ),
    );
  }
}

class _YellowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _YellowButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
  });

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
        lowerBound: 0.97,
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
          height: 56,
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? Colors.grey.shade600
                : const Color(0xFFF5C518),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.onPressed == null
                ? []
                : [
              BoxShadow(
                color:
                const Color(0xFFF5C518).withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Color(0xFF1C2331),
                strokeWidth: 2.5,
              ),
            )
                : Text(
              widget.label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1C2331),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFF2D3748)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: GoogleFonts.poppins(
              color: const Color(0xFF8A9BB0),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFF2D3748)),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3748), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google G
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'G',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF5C518),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Google',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontSize: 12)),
          ),
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
          offset: Offset(0, 28 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}