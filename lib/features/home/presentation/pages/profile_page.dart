// Adapted account/profile UI from feature/ui-thien
// Uses Stream from ProfileRepository and Riverpod ConsumerWidget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:calories_app/data/firebase/profile_repository.dart';
import 'package:calories_app/services/profile_service.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'package:calories_app/ui/components/avatar_circle.dart';
import 'package:calories_app/ui/components/macro_ring.dart';
import 'package:calories_app/ui/screens/account/physical_profile_screen.dart';
import 'package:calories_app/ui/screens/account/targets_screen.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ProfileRepository();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.settings, size: 20),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // no-op: could call repo.watchCurrentProfile but it's a stream
          return Future.value();
        },
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: repo.watchCurrentProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data ?? {};
            final name =
                profile['nickname'] ?? user?.displayName ?? 'Người dùng';
            final updatedAt = profile['createdAt'] is String
                ? DateTime.tryParse(profile['createdAt'])
                : null;
            final currentCalories = 850;
            final targetCalories = (profile['targetKcal'] is num)
                ? (profile['targetKcal'] as num).toInt()
                : 2000;

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AvatarCircle(
                        size: 84,
                        avatarUrl: profile['avatarUrl'] as String?,
                        onAvatarPicked: (xfile) async {
                          if (xfile == null) return;
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Không có người dùng hiện tại'),
                                ),
                              );
                            }
                            return;
                          }
                          try {
                            final service = await ProfileService.create();
                            final url = await service.uploadAvatar(uid, xfile);
                            if (url != null) {
                              // Update the canonical profile (profiles subcollection)
                              final service = await ProfileService.create();
                              await service.updateCurrentProfileFields(uid, {
                                'avatarUrl': url,
                              });
                            }
                          } catch (e) {
                            debugPrint('upload avatar failed: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tải ảnh thất bại: $e')),
                              );
                            }
                          }
                        },
                        onUrlSubmitted: (url) async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;
                          try {
                            final service = await ProfileService.create();
                            await service.updateCurrentProfileFields(uid, {
                              'avatarUrl': url,
                            });
                          } catch (e) {
                            debugPrint('set avatar url failed: $e');
                          }
                        },
                        onClear: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;
                          try {
                            final service = await ProfileService.create();
                            await service.updateCurrentProfileFields(uid, {
                              'avatarUrl': null,
                            });
                          } catch (e) {
                            debugPrint('clear avatar failed: $e');
                          }
                        },
                      ),
                      Positioned(
                        right:
                            MediaQuery.of(context).size.width / 2 - 84 / 2 - 8,
                        bottom: 6,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit_profile'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    updatedAt != null
                        ? 'Đã tham gia từ ${_formatJoinDate(updatedAt)}'
                        : 'Đã tham gia',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statChip(
                          context,
                          Icons.calendar_today_outlined,
                          '${profile['age'] ?? '--'} tuổi',
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        _statChip(
                          context,
                          Icons.accessibility_new,
                          profile['heightCm'] != null
                              ? '${profile['heightCm'].toString()} cm'
                              : '--',
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        _statChip(
                          context,
                          Icons.monitor_weight_outlined,
                          profile['weightKg'] != null
                              ? '${(profile['weightKg'] as num).toStringAsFixed(0)} kg'
                              : '--',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhysicalProfileScreen(),
                    ),
                  ),
                  child: const Text(
                    'Hồ sơ thể chất',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 18),

                _journeyCard(context, profile),
                const SizedBox(height: 18),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mục tiêu dinh dưỡng & đa lượng',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            MacroRing(
                              currentCalories: currentCalories,
                              targetCalories: targetCalories,
                              size: 110,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _macroRow(
                                    context,
                                    'Chất đạm',
                                    '20%',
                                    '88g',
                                    Colors.red,
                                  ),
                                  const SizedBox(height: 6),
                                  _macroRow(
                                    context,
                                    'Đường bột',
                                    '50%',
                                    '219g',
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 6),
                                  _macroRow(
                                    context,
                                    'Chất béo',
                                    '30%',
                                    '58g',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TargetsScreen(),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Tùy chỉnh mục tiêu'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Xem báo cáo thống kê',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconTile(
                      context,
                      Icons.restaurant,
                      'Dinh dưỡng',
                      route: '/report/nutrition',
                    ),
                    _iconTile(
                      context,
                      Icons.fitness_center,
                      'Tập luyện',
                      route: '/report/workout',
                    ),
                    _iconTile(
                      context,
                      Icons.directions_walk,
                      'Số bước',
                      route: '/report/steps',
                    ),
                    _iconTile(
                      context,
                      Icons.scale,
                      'Cân nặng',
                      route: '/report/weight',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Card(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gia nhập cộng đồng ngay!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bạn đã vào group chưa? Nơi cộng đồng sẽ đồng hành cùng bạn.',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/community'),
                          child: const Text('Tham gia ngay'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Tìm ứng dụng trên trang mạng xã hội',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _socialTile(context, Icons.music_note, 'Tiktok'),
                    _socialTile(context, Icons.facebook, 'Facebook'),
                    _socialTile(context, Icons.camera_alt, 'Instagram'),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => _showLogoutDialog(context, ref),
                    child: const Text('Đăng xuất'),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Calories App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Phiên bản: 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '© Calories App 2024. All Rights Reserved',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month;
    final y = dt.year;
    return '$d Thg $m, $y';
  }

  Widget _statChip(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _journeyCard(BuildContext context, Map<String, dynamic> profile) {
    final weight = (profile['weightKg'] is num)
        ? (profile['weightKg'] as num).toDouble()
        : 57.0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành trình của bạn',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withAlpha(31),
                    Theme.of(context).colorScheme.primary.withAlpha(10),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 42,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn đang duy trì cân nặng rất tốt!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cập nhật lại cân nặng để xem tiến trình',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Slider.adaptive(
                      value: weight.toDouble().clamp(30, 120),
                      onChanged: (_) {},
                      min: 30,
                      max: 120,
                    ),
                    Center(
                      child: Text(
                        '${weight.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.bodyLarge,
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

  Widget _macroRow(
    BuildContext context,
    String name,
    String pct,
    String grams,
    Color color,
  ) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Expanded(child: Text(name)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(pct, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('($grams)', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _iconTile(
    BuildContext context,
    IconData icon,
    String label, {
    String? route,
  }) {
    final child = Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
    final content = route == null
        ? child
        : GestureDetector(
            onTap: () => Navigator.pushNamed(context, route),
            child: child,
          );
    return Expanded(child: content);
  }

  Widget _socialTile(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _handleSignOut(dialogContext, ref);
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      final googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      // Invalidate Riverpod providers to clear app state
      ref.invalidate(currentProfileProvider);
      ref.invalidate(onboardingControllerProvider);
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/intro', (route) => false);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Components `AvatarCircle` and `MacroRing` are provided in
// `lib/ui/components/` (copied from feature/ui-thien).

// Placeholder screens used for navigation targets when real screens are not present
class PhysicalProfileScreenPlaceholder extends StatelessWidget {
  const PhysicalProfileScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ thể chất')),
    body: const Center(child: Text('Physical profile screen (placeholder)')),
  );
}

class TargetsScreenPlaceholder extends StatelessWidget {
  const TargetsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mục tiêu')),
    body: const Center(child: Text('Targets screen (placeholder)')),
  );
}
