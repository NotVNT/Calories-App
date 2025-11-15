import 'package:flutter/material.dart';
import 'package:calories_app/features/auth/data/auth_service.dart';
import 'package:calories_app/features/auth/presentation/theme/auth_theme.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onSignUpPressed;
  final VoidCallback? onForgotPasswordPressed;

  const SignInScreen({
    super.key,
    this.onSignUpPressed,
    this.onForgotPasswordPressed,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn({bool forceAccountSelection = false}) async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle(forceAccountSelection: forceAccountSelection);
      // Auth state change will trigger AuthPage to show ProfileGate
      // No need to navigate manually
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Auth state change will trigger AuthPage to show ProfileGate
      // No need to navigate manually
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.palePink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthTheme.spacingXLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AuthTheme.spacingXLarge),
                // App Title
                Text(
                  'Ăn Khỏe',
                  style: AuthTheme.headlineStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuthTheme.spacingSmall),
                Text(
                  'Healthy Choice',
                  style: AuthTheme.bodyStyle.copyWith(
                    fontSize: 18,
                    color: AuthTheme.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuthTheme.spacingXLarge * 2),

                // Google Sign In Button (Primary - Fast Login)
                _GoogleSignInButton(
                  onPressed: _isLoading ? null : () => _handleGoogleSignIn(forceAccountSelection: false),
                ),
                const SizedBox(height: AuthTheme.spacingSmall),
                
                // Secondary button for account chooser
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _handleGoogleSignIn(forceAccountSelection: true),
                    child: Text(
                      'Đăng nhập bằng tài khoản khác',
                      style: AuthTheme.linkTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AuthTheme.charmingGreen)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AuthTheme.spacingMedium,
                      ),
                      child: Text(
                        'hoặc',
                        style: AuthTheme.bodyStyle,
                      ),
                    ),
                    Expanded(child: Divider(color: AuthTheme.charmingGreen)),
                  ],
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Email Field
                _CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Nhập email của bạn',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AuthTheme.spacingMedium),

                // Password Field
                _CustomTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AuthTheme.mediumGray,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AuthTheme.spacingSmall),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onForgotPasswordPressed,
                    child: Text(
                      'Quên mật khẩu?',
                      style: AuthTheme.linkTextStyle,
                    ),
                  ),
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Sign In Button
                _PrimaryButton(
                  text: 'Đăng nhập',
                  icon: Icons.login,
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: AuthTheme.bodyStyle,
                    ),
                    TextButton(
                      onPressed: widget.onSignUpPressed,
                      child: Text(
                        'Đăng ký',
                        style: AuthTheme.linkTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AuthTheme.buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
        boxShadow: AuthTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AuthTheme.spacingMedium),
              Text(
                'Đăng nhập với Google',
                style: AuthTheme.buttonTextStyle.copyWith(
                  color: AuthTheme.nearBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AuthTheme.buttonHeight,
      decoration: BoxDecoration(
        color: onPressed == null
            ? AuthTheme.charmingGreen
            : AuthTheme.mintGreen,
        borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
        boxShadow: AuthTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(icon, color: Colors.white),
              if (!isLoading) const SizedBox(width: AuthTheme.spacingMedium),
              Text(
                text,
                style: AuthTheme.buttonTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AuthTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AuthTheme.nearBlack,
          ),
        ),
        const SizedBox(height: AuthTheme.spacingSmall),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
            boxShadow: AuthTheme.softShadow,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AuthTheme.bodyStyle.copyWith(
                color: AuthTheme.mediumGray.withAlpha((0.6 * 255).round()),
              ),
              prefixIcon: Icon(prefixIcon, color: AuthTheme.mintGreen),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.borderRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AuthTheme.spacingMedium,
                vertical: AuthTheme.spacingMedium,
              ),
            ),
            style: AuthTheme.bodyStyle.copyWith(
              color: AuthTheme.nearBlack,
            ),
          ),
        ),
      ],
    );
  }
}


