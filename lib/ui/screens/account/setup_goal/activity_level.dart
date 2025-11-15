import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  int _selected = 0;

  final List<Map<String, String>> _levels = const [
    {
      'title': 'Không tập luyện, ít vận động',
      'bullets':
          '- Đi bộ < 3.000 bước/ngày.\n- Công việc ngồi nhiều, ít di chuyển.\n- Không tập thể dục hoặc dưới 15 phút/ngày.',
    },
    {
      'title': 'Vận động nhẹ nhàng',
      'bullets': 'Đi bộ nhẹ, hoạt động hàng ngày',
    },
    {'title': 'Chăm chỉ luyện tập', 'bullets': 'Tập 3-4 lần/tuần'},
    {'title': 'Rất năng động', 'bullets': 'Tập đều, lao động tay chân'},
    {
      'title': 'Cực kỳ năng động',
      'bullets': 'Hoạt động thể lực cao, hàng ngày',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final goalTitle = args['goalTitle'] as String? ?? '';
    final weight = args['weight'] as double? ?? 57.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.75,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(24),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cường độ tập luyện trong tuần của bạn là...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: _levels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final selected = idx == _selected;
                  final level = _levels[idx];
                  return InkWell(
                    onTap: () => setState(() => _selected = idx),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            level['bullets']!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/setup_goal/summary',
                          arguments: {
                            'goalTitle': goalTitle,
                            'weight': weight,
                            'activityIndex': _selected,
                            'activityLabel': _levels[_selected]['title'],
                          },
                        );
                      },
                      child: const Text('Tiếp tục'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
