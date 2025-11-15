// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

class StepsTargetScreen extends StatefulWidget {
  const StepsTargetScreen({super.key});

  @override
  State<StepsTargetScreen> createState() => _StepsTargetScreenState();
}

class _StepsTargetScreenState extends State<StepsTargetScreen> {
  late int _selected;
  late int _initialSelected;

  final List<Map<String, Object>> _options = [
    {
      'key': 'sedentary',
      'label': 'Ít vận động',
      'steps': 3000,
      'icon': Icons.chair,
    },
    {
      'key': 'light',
      'label': 'Nhẹ nhàng',
      'steps': 5000,
      'icon': Icons.self_improvement,
    },
    {
      'key': 'moderate',
      'label': 'Trung bình',
      'steps': 8000,
      'icon': Icons.directions_walk,
    },
    {
      'key': 'active',
      'label': 'Rất năng động',
      'steps': 10000,
      'icon': Icons.run_circle,
    },
    {
      'key': 'very_active',
      'label': 'Cực kỳ năng động',
      'steps': 12000,
      'icon': Icons.sports_motorsports,
    },
  ];

  @override
  void initState() {
    super.initState();
    // default set in didChangeDependencies
    _selected = _options[0]['steps'] as int;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.read<ProfileProvider>().profile;
    final goal = profile.goal;
    if (goal.startsWith('steps:')) {
      final parts = goal.split(':');
      if (parts.length > 1) {
        final n = int.tryParse(parts[1]);
        if (n != null) _selected = n;
      }
    }
    _initialSelected = _selected;
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r"\B(?=(\d{3})+(?!\d))"),
    (m) => ',',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều chỉnh mục tiêu'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          TextButton(
            onPressed: _selected == _initialSelected
                ? null
                : () async {
                    final prov = context.read<ProfileProvider>();
                    final current = prov.profile;
                    final value = 'steps:$_selected';
                    await prov.updateProfile(current.copyWith(goal: value));
                    if (mounted) Navigator.of(context).pop(true);
                  },
            child: Text(
              'Lưu',
              style: theme.textTheme.titleSmall?.copyWith(
                color: _selected == _initialSelected
                    ? theme.disabledColor
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mục tiêu bước chân', style: theme.textTheme.titleMedium),
              Text(
                '${_fmt(_selected)} Bước',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dựa vào mức độ vận động bạn đã chọn, Wao gợi ý số bước phù hợp. Bạn vẫn có thể tự điều chỉnh mục tiêu theo nhu cầu.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Gợi ý mục tiêu bước chân',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(_options.length, (i) {
                final opt = _options[i];
                final steps = opt['steps'] as int;
                final label = opt['label'] as String;
                final icon = opt['icon'] as IconData;
                final selected = steps == _selected;
                return Column(
                  children: [
                    ListTile(
                      tileColor: selected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      leading: Icon(
                        icon,
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        label,
                        style: selected
                            ? theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _fmt(steps),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'bước/ngày',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      selected: selected,
                      onTap: () => setState(() => _selected = steps),
                    ),
                    if (i != _options.length - 1) const Divider(height: 1),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
