// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class WaterTargetScreen extends StatefulWidget {
  const WaterTargetScreen({super.key});

  @override
  State<WaterTargetScreen> createState() => _WaterTargetScreenState();
}

class _WaterTargetScreenState extends State<WaterTargetScreen> {
  double _liters = 2.0;
  int _selectedVolumeMl = 200; // 200ml glass or 500ml bottle

  @override
  void initState() {
    super.initState();
    // default values; could read from profile if desired
  }

  void _changeBy(double delta) {
    setState(() {
      _liters = (_liters + delta).clamp(1.0, 4.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final litersLabel = _liters % 1 == 0
        ? _liters.toInt().toString()
        : _liters.toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu nước uống'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Lượng nước cần uống trong ngày',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            // Center liters
            Center(
              child: Text(
                '$litersLabel lít',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Slider with minus/plus
            Row(
              children: [
                _circleIconButton(Icons.remove, () => _changeBy(-0.25)),
                const SizedBox(width: 12),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Slider(
                      min: 1.0,
                      max: 4.0,
                      divisions: 30,
                      value: _liters,
                      onChanged: (v) => setState(() => _liters = v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _circleIconButton(Icons.add, () => _changeBy(0.25)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Text('1 lít'), Text('4 lít')],
              ),
            ),

            const SizedBox(height: 28),
            Text(
              'Dung tích mỗi lần ghi lại',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _volumeCard('Ly nước', '200ml', 200, context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _volumeCard('Chai nước', '500ml', 500, context),
                  ),
                ],
              ),
            ),

            // Update button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 12.0,
              ),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () async {
                    final prov = context.read<ProfileProvider>();
                    final current = prov.profile;
                    // store as simple string: water:<ml>
                    final totalMl = (_liters * 1000).round();
                    final value = 'water:$totalMl;unit:$_selectedVolumeMl';
                    await prov.updateProfile(current.copyWith(goal: value));
                    if (mounted) Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Cập nhật',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha((0.08 * 255).round()),
          ),
        ),
        child: Center(child: Icon(icon)),
      ),
    );
  }

  Widget _volumeCard(
    String title,
    String subtitle,
    int ml,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final selected = _selectedVolumeMl == ml;
    return GestureDetector(
      onTap: () => setState(() => _selectedVolumeMl = ml),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // placeholder image
            SizedBox(
              height: 90,
              child: Icon(
                Icons.local_drink,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
