import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/otp_service.dart';
import 'dart:async';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  // OTP flow state
  bool _otpSent = false;
  bool _otpVerified = false;
  final _otpCtrl = TextEditingController();
  // countdown & retry
  Timer? _otpTimer;
  int _otpSecondsLeft = 0;
  int _otpRetries = 0;
  static const int _otpMaxRetries = 3;
  static const int _otpCooldownSeconds = 60;

  String _formatSeconds(int s) {
    final minutes = s ~/ 60;
    final seconds = s % 60;
    if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _otpCtrl.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendResetEmail(BuildContext ctx, String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Không có email để gửi')));
      return;
    }
    final messenger = ScaffoldMessenger.of(ctx);
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hòm thư.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gửi email thất bại: $e')));
    }
  }

  Future<void> _sendOtp(BuildContext ctx, String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Không có email để gửi')));
      return;
    }
    final messenger = ScaffoldMessenger.of(ctx);
    if (_otpRetries >= _otpMaxRetries) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã đạt giới hạn số lần gửi OTP.')),
      );
      return;
    }
    if (_otpSecondsLeft > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chờ ${_formatSeconds(_otpSecondsLeft)} trước khi gửi lại',
          ),
        ),
      );
      return;
    }
    try {
      final code = await OtpService.requestOtp(email);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Mã OTP đã được sinh; kiểm tra console debug (dev).'),
        ),
      );
      setState(() {
        _otpSent = true;
        _otpVerified = false;
        _otpRetries += 1;
        _otpSecondsLeft = _otpCooldownSeconds;
      });
      _otpTimer?.cancel();
      _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_otpSecondsLeft <= 1) {
          t.cancel();
          setState(() => _otpSecondsLeft = 0);
        } else {
          setState(() => _otpSecondsLeft -= 1);
        }
      });
      // ignore: avoid_print
      print('DEV OTP for $email: $code');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gửi OTP thất bại: $e')));
    }
  }

  Future<void> _verifyOtp(BuildContext ctx, String? email) async {
    final messenger = ScaffoldMessenger.of(ctx);
    final code = _otpCtrl.text.trim();
    if (code.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Nhập mã OTP')));
      return;
    }
    final ok = await OtpService.verifyOtp(email ?? '', code);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Xác thực mã thành công')),
      );
      setState(() => _otpVerified = true);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Mã không hợp lệ hoặc đã hết hạn')),
      );
    }
  }

  Future<void> _changeInApp(BuildContext ctx) async {
    final provider = context.read<ProfileProvider>();
    final current = _currentCtrl.text.trim();
    final nw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (current.isEmpty || nw.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ các trường.')),
      );
      return;
    }
    if (nw != confirm) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp.')),
      );
      return;
    }

    // capture messenger and navigator before async gaps
    final messenger = ScaffoldMessenger.of(ctx);
    final navigator = Navigator.of(ctx);
    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) throw StateError('Không có người dùng đăng nhập');

      // Reauthenticate with email+current password so updatePassword succeeds
      final email = user.email;
      if (email == null) throw StateError('Người dùng chưa có email');
      final cred = EmailAuthProvider.credential(
        email: email,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      // Now update password via the service/provider
      await provider.changePassword(nw);

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công')),
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final email = profile.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Phương thức an toàn',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gửi email xác nhận',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email ?? 'Không có email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: email == null
                                ? null
                                : () => _sendResetEmail(context, email),
                            child: const Text('Gửi link tới email'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (email == null ||
                                    _otpRetries >= _otpMaxRetries ||
                                    _otpSecondsLeft > 0)
                                ? null
                                : () => _sendOtp(context, email),
                            child: const Text('Gửi mã OTP (dev)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_otpSecondsLeft > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Text(
                              'Gửi lại sau: ${_formatSeconds(_otpSecondsLeft)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        Text(
                          'Lượt còn lại: ${(_otpMaxRetries - _otpRetries).clamp(0, _otpMaxRetries)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lưu ý: Hệ thống sẽ gửi một email để đặt lại mật khẩu. Nếu bạn muốn thay đổi ngay trong ứng dụng, hãy xác thực bằng mật khẩu hiện tại ở phần bên dưới.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // OTP verification card (dev stub)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (_otpSent && !_otpVerified) ...[
                      TextField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Mã OTP'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _verifyOtp(context, email),
                              child: const Text('Xác thực mã'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _otpSent = false;
                                  _otpVerified = false;
                                  _otpCtrl.clear();
                                  _otpTimer?.cancel();
                                  _otpSecondsLeft = 0;
                                });
                              },
                              child: const Text('Huỷ'),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                    ],
                    if (_otpVerified) ...[
                      const Text(
                        'OTP đã xác thực — nhập mật khẩu mới bên dưới',
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (!_otpSent) const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Đổi ngay trong ứng dụng',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _currentCtrl,
                      obscureText: !_showCurrent,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu hiện tại',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _showCurrent = !_showCurrent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newCtrl,
                      obscureText: !_showNew,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showNew ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _showNew = !_showNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: !_showConfirm,
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _showConfirm = !_showConfirm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _changeInApp(context),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Đổi mật khẩu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
