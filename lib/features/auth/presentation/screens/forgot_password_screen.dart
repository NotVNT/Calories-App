import 'package:flutter/material.dart';
import 'package:calories_app/features/auth/data/auth_service.dart';
import 'package:calories_app/features/auth/presentation/theme/auth_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi email thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AuthTheme.nearBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthTheme.spacingXLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AuthTheme.spacingLarge),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AuthTheme.mintGreen,
                    shape: BoxShape.circle,
                    boxShadow: AuthTheme.softShadow,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AuthTheme.spacingXLarge),
                // Title
                Text(
                  'Quên mật khẩu?',
                  style: AuthTheme.headlineStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuthTheme.spacingMedium),
                if (_emailSent)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AuthTheme.spacingLarge),
                        decoration: BoxDecoration(
                          color: AuthTheme.mintGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AuthTheme.borderRadius,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: AuthTheme.mintGreen,
                            ),
                            const SizedBox(height: AuthTheme.spacingMedium),
                            Text(
                              'Email đã được gửi!',
                              style: AuthTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AuthTheme.nearBlack,
                              ),
                            ),
                            const SizedBox(height: AuthTheme.spacingSmall),
                            Text(
                              'Vui lòng kiểm tra hộp thư của bạn và làm theo hướng dẫn để đặt lại mật khẩu.',
                              style: AuthTheme.bodyStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AuthTheme.spacingXLarge),
                      _PrimaryButton(
                        text: 'Quay lại đăng nhập',
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Nhập email của bạn và chúng tôi sẽ gửi cho bạn liên kết để đặt lại mật khẩu.',
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
                      const SizedBox(height: AuthTheme.spacingXLarge),
                      // Send Button
                      _PrimaryButton(
                        text: 'Gửi email đặt lại mật khẩu',
                        icon: Icons.send,
                        onPressed: _isLoading ? null : _handleResetPassword,
                        isLoading: _isLoading,
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

// Reuse components
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
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
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AuthTheme.bodyStyle.copyWith(
                color: AuthTheme.mediumGray.withOpacity(0.6),
              ),
              prefixIcon: Icon(prefixIcon, color: AuthTheme.mintGreen),
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

