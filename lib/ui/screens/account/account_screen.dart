// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/avatar_circle.dart';
import '../../components/macro_ring.dart';
import '../../../providers/profile_provider.dart';
import 'targets_screen.dart';
import 'physical_profile_screen.dart';

/// Main Account screen showing avatar, stats and navigation.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    // Example calorie numbers for display; current is demo value, target comes from profile if set.
    const current = 850;
    final target = profile.calorieTarget ?? 2000;

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
        onRefresh: () => provider.load(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Header: avatar, name, join date
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AvatarCircle(size: 84),
                  Positioned(
                    right: MediaQuery.of(context).size.width / 2 - 84 / 2 - 8,
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
                          boxShadow: [
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
                profile.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                profile.updatedAt != null
                    ? 'Đã tham gia từ ${_formatJoinDate(profile.updatedAt!)}'
                    : 'Đã tham gia',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),

            // Stats chips row
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
                      '${_computeAge(profile)} tuổi',
                    ),
                    Container(
                      height: 28,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    _statChip(
                      context,
                      Icons.accessibility_new,
                      profile.heightCm != null
                          ? '${profile.heightCm!.toInt()} cm'
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
                      profile.weightKg != null
                          ? '${profile.weightKg!.toStringAsFixed(0)} kg'
                          : '--',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Big physical profile button
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

            // Journey card (weight progress)
            _journeyCard(context, profile),
            const SizedBox(height: 18),

            // Nutrition target card
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
                          currentCalories: current,
                          targetCalories: target,
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

            // Quick stats icons
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

            // Community banner
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
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

            // Social icons row
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
            const SizedBox(height: 28),

            // Footer
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
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime dt) {
    // Simple date format: 04 Thg 11, 2025
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month;
    final y = dt.year;
    return '$d Thg $m, $y';
  }

  String _computeAge(profile) {
    // Best-effort; profile has no birthdate so return '--'
    return '--';
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

  Widget _journeyCard(BuildContext context, profile) {
    final weight = profile.weightKg ?? 57.0;
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
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    Theme.of(context).colorScheme.primary.withOpacity(0.04),
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
}
