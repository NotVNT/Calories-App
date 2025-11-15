import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

/// A dialog that performs reauthentication directly (either password or
/// Google) and shows a spinner while the operation is in progress. The
/// dialog accepts no external callbacks; it will call provider helpers to
/// perform the reauth (and optional deletion) so the caller only needs to
/// await the dialog result.
class ReauthDialog extends StatefulWidget {
  /// If [performDeleteAfterReauth] is true, the dialog will call the
  /// provider's reauthenticate+delete helpers so the dialog both reauths and
  /// deletes the account. If false, the dialog will only reauthenticate.
  final bool performDeleteAfterReauth;

  const ReauthDialog({super.key, this.performDeleteAfterReauth = true});

  @override
  State<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<ReauthDialog> {
  final TextEditingController _pwdController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _pwdController.dispose();
    super.dispose();
  }

  Future<void> _handlePassword(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final pwd = _pwdController.text.trim();
    if (pwd.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mật khẩu.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      if (widget.performDeleteAfterReauth) {
        await provider.reauthenticateAndDelete(pwd);
      } else {
        await provider.reauthenticateWithPassword(pwd);
      }
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Xác thực thất bại.')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isProcessing = true);
    try {
      if (widget.performDeleteAfterReauth) {
        await provider.reauthenticateWithGoogleAndDelete();
      } else {
        await provider.reauthenticateWithGoogleAndDelete();
      }
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Đăng nhập Google thất bại.')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác thực lại'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vui lòng xác thực lại để thực hiện hành động nhạy cảm.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu hiện tại',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: Divider()),
                SizedBox(width: 8),
                Text('Hoặc'),
                SizedBox(width: 8),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Image.asset(
                  'assets/icons/google_logo.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (c, e, s) => Image.network(
                    'https://developers.google.com/identity/images/g-logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (c2, e2, s2) => const Icon(Icons.login),
                  ),
                ),
                label: const Text('Đăng nhập bằng Google'),
                onPressed: _isProcessing ? null : () => _handleGoogle(context),
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _isProcessing ? null : () => _handlePassword(context),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
