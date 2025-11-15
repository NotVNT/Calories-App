import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final uid = context.watch<ProfileProvider>().uid;

    String truncateUid(String id) {
      if (id.length <= 16) return id;
      return '${id.substring(0, 8)}...${id.substring(id.length - 4)}';
    }

    Widget buildRow({
      required Widget leading,
      required String title,
      String? subtitle,
      VoidCallback? onTap,
      Widget? trailing,
    }) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'THÔNG TIN CƠ BẢN',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                buildRow(
                  leading: const Icon(Icons.badge_outlined),
                  title: 'UID',
                  subtitle: truncateUid(uid),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UID đã sao chép')),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                buildRow(
                  leading: const Icon(Icons.email_outlined),
                  title: profile.email != null ? 'Email' : 'Email (chưa có)',
                  subtitle: profile.email ?? '—',
                  onTap: () => Navigator.pushNamed(context, '/edit_email'),
                ),
                const Divider(height: 1),
                buildRow(
                  leading: const Icon(Icons.description_outlined),
                  title: 'Điều khoản sử dụng',
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                const Divider(height: 1),
                buildRow(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: 'Chính sách quyền riêng tư',
                  onTap: () => Navigator.pushNamed(context, '/privacy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'TÀI KHOẢN VÀ BẢO MẬT',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                buildRow(
                  leading: const Icon(Icons.delete_outline),
                  title: 'Xoá dữ liệu và tài khoản',
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final provider = context.read<ProfileProvider>();
                    final navigator = Navigator.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: const Text(
                          'Bạn có chắc muốn xoá dữ liệu và tài khoản? Hành động này không thể hoàn tác.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Xoá'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await provider.deleteAccount();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Tài khoản đã được xoá (local).'),
                        ),
                      );
                      navigator.pushReplacementNamed('/login');
                    }
                  },
                ),
                const Divider(height: 1),
                // Note: Sign-out is now provided outside settings UI.
                // Removed in-settings logout entry to avoid duplication.
                buildRow(
                  leading: const Icon(Icons.lock_outline),
                  title: 'Đổi mật khẩu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
