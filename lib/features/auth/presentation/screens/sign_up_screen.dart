import 'package:flutter/material.dart';
import 'package:calories_app/features/auth/data/auth_service.dart';
import 'package:calories_app/features/auth/presentation/theme/auth_theme.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignInPressed;

  const SignUpScreen({
    super.key,
    this.onSignInPressed,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Auth state change will trigger AuthPage to show ProfileGate
      // No need to navigate manually
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
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
                  'Tạo tài khoản',
                  style: AuthTheme.headlineStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuthTheme.spacingSmall),
                Text(
                  'Đăng ký để bắt đầu hành trình ăn khỏe',
                  style: AuthTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuthTheme.spacingXLarge * 2),

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
                  hint: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
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
                const SizedBox(height: AuthTheme.spacingMedium),

                // Confirm Password Field
                _CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AuthTheme.mediumGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Sign Up Button
                _PrimaryButton(
                  text: 'Đăng ký',
                  icon: Icons.person_add,
                  onPressed: _isLoading ? null : _handleSignUp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AuthTheme.spacingLarge),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: AuthTheme.bodyStyle,
                    ),
                    TextButton(
                      onPressed: widget.onSignInPressed,
                      child: Text(
                        'Đăng nhập',
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

// Reuse components from sign_in_screen
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


