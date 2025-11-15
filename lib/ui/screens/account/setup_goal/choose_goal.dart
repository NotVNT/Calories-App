import 'package:flutter/material.dart';

class ChooseGoalScreen extends StatefulWidget {
  const ChooseGoalScreen({super.key});

  @override
  State<ChooseGoalScreen> createState() => _ChooseGoalScreenState();
}

class _ChooseGoalScreenState extends State<ChooseGoalScreen> {
  int _selected = 2; // default: duy trì

  final List<Map<String, String>> _options = const [
    {'title': 'Giảm cân', 'subtitle': 'Tập trung vào giảm mỡ'},
    {
      'title': 'Tăng cân',
      'subtitle': 'Xây dựng cơ bắp, khỏe mạnh từ bên trong',
    },
    {
      'title': 'Duy trì cân nặng',
      'subtitle': 'Vừa đốt mỡ, vừa tăng cơ để có body săn chắc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              value: 0.25,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(24),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mục tiêu cân nặng của bạn',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemBuilder: (ctx, idx) {
                  final opt = _options[idx];
                  final selected = idx == _selected;
                  return InkWell(
                    onTap: () => setState(() => _selected = idx),
                    child: Container(
                      padding: const EdgeInsets.all(18),
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
                            opt['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            opt['subtitle']!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _options.length,
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
                          '/setup_goal/weight',
                          arguments: {
                            'goalIndex': _selected,
                            'goalTitle': _options[_selected]['title'],
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
