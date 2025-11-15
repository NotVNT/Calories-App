import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../providers/profile_provider.dart';
import '../../../providers/foods_provider.dart';
import '../../../providers/health_connect_provider.dart';
import 'compare_journey_sheet.dart';
import 'steps_target_screen.dart';
import '../../components/empty_state.dart';
import '../../../utils/data_format.dart';

/// A reusable purple action button shown when Health Connect is not connected.
class HealthConnectActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const HealthConnectActionButton({
    required this.text,
    required this.onPressed,
    this.icon = Icons.health_and_safety,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportScreen extends StatelessWidget {
  final String title;
  const ReportScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // If this is the nutrition screen, show the NutritionReport widget.
    if (title == 'Dinh dưỡng') {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const NutritionReport(),
      );
    }

    // show Weight / Scale report when title indicates weight
    final lower = title.toLowerCase();
    if (lower.contains('cân') ||
        lower.contains('cân nặng') ||
        lower.contains('thống kê cân') ||
        lower.contains('weight')) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const WeightReport(),
      );
    }

    // show Steps / Pedometer report when title indicates steps/activity
    if (lower.contains('bước') ||
        lower.contains('step') ||
        lower.contains('steps') ||
        lower.contains('bước chân') ||
        lower.contains('step chân')) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const StepsReport(),
      );
    }

    if (lower.contains('tập') ||
        lower.contains('hoạt') ||
        title == 'Tập luyện' ||
        title == 'Thống kê hoạt động') {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const ActivityReport(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Báo cáo cho "$title" sẽ hiển thị ở đây (placeholder).'),
        ),
      ),
    );
  }
}

class ActivityReport extends StatefulWidget {
  const ActivityReport({super.key});

  @override
  State<ActivityReport> createState() => _ActivityReportState();
}

/// Steps / Pedometer report screen (mirrors ActivityReport but tailored for steps)
class StepsReport extends StatefulWidget {
  const StepsReport({super.key});

  @override
  State<StepsReport> createState() => _StepsReportState();
}

/// Weight / Scale report screen (mirror of mockups)
class WeightReport extends StatefulWidget {
  const WeightReport({super.key});

  @override
  State<WeightReport> createState() => _WeightReportState();
}

class _WeightReportState extends State<WeightReport> {
  int _period = 0; // 0=1 tháng,1=6 tháng,2=12 tháng

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmi = 22.3; // placeholder until real data available
    // map BMI to marker position (assume scale from 15..35)
    double fractionForBmi(double v) =>
        ((v - 15.0) / (35.0 - 15.0)).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedControl3(
                value: _period,
                onValueChanged: (v) => setState(() => _period = v),
                leftLabel: '1 tháng',
                middleLabel: '6 tháng',
                rightLabel: '12 tháng',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            const SizedBox(width: 8),
            Text(
              _period == 0
                  ? 'Tháng ${DateTime.now().month}'
                  : (_period == 1 ? '6 tháng gần nhất' : '12 tháng gần nhất'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 12),

        // Chart area (placeholder; show empty state or simple line)
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Biểu đồ cân nặng', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: EmptyState(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Chưa có dữ liệu',
                        message:
                            'Kết nối Health Connect để tự động cập nhật cân nặng.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // legend + Health Connect card
        Row(
          children: [
            Expanded(
              child: Text('Đường mục tiêu', style: theme.textTheme.bodySmall),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Dữ liệu ghi nhận', style: theme.textTheme.bodySmall),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Show suggestion button only when Weight is not connected
        Builder(
          builder: (ctx) {
            final hc = ctx.watch<HealthConnectProvider>();
            if (hc.connectedWeight) return const SizedBox.shrink();
            return HealthConnectActionButton(
              text: 'Kết nối Health Connect để tự động cập nhật.',
              onPressed: () {
                showModalBottomSheet<void>(
                  context: ctx,
                  builder: (sheetCtx) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết nối Health Connect',
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cho phép Wao đọc dữ liệu cân nặng từ thiết bị để tự động đồng bộ.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(sheetCtx).pop(),
                                child: const Text('Hủy'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(sheetCtx).pop();
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Chức năng kết nối chưa được triển khai ở bản demo.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Kết nối'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),

        // three stat boxes (Ban đầu / Hiện tại / Thay đổi)
        Row(
          children: const [
            Expanded(
              child: _WeightStatCard(label: 'BAN ĐẦU', value: '57 kg'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _WeightStatCard(label: 'HIỆN TẠI', value: '57 kg'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _WeightStatCard(label: 'THAY ĐỔI', value: '- kg'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // share button -> open share journey screen
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed('/report/share'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('Chia sẻ hành trình'),
        ),
        const SizedBox(height: 16),

        // (Removed duplicate Health Connect CTA — weight screen already shows a context-specific button)

        // BMI scale with marker
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 16,
                        color: const Color(0xFFE6F7FF),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 16,
                        color: const Color(0xFFDFF7E6),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 16,
                        color: const Color(0xFFFFF3D9),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 16,
                        color: const Color(0xFFFFE6E6),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 16,
                        color: const Color(0xFFFFD9E6),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left:
                      MediaQuery.of(context).size.width *
                      (fractionForBmi(bmi) * 0.9),
                  top: -6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('< 15'),
                Text('18.5'),
                Text('22.9'),
                Text('24.9'),
                Text('29.9'),
                Text('>= 35'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // BMI card and history
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('BMI của bạn:', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Text(
                      bmi.toStringAsFixed(1),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Bình thường',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đang ở mức cân nặng hợp lý. Hãy duy trì thói quen lành mạnh để bảo vệ sức khỏe lâu dài.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        ListTile(
          title: const Text('Lịch sử cân nặng'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.monitor_weight)),
            title: const Text('57 kg'),
            subtitle: Text(
              'Ghi bởi Wao • ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}',
            ),
            trailing: const Text(
              '04/11',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CompareJourneySheet(),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('So sánh ảnh trước và sau'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _WeightStatCard extends StatelessWidget {
  final String label;
  final String value;
  const _WeightStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StepsReportState extends State<StepsReport> {
  int _period = 0; // 0=Tuần,1=Tháng,2=6 Tháng

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedControl3(
                value: _period,
                onValueChanged: (v) => setState(() => _period = v),
                leftLabel: 'Tuần',
                middleLabel: 'Tháng',
                rightLabel: '6 Tháng',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            const SizedBox(width: 8),
            Text(
              _period == 0
                  ? 'Tuần hiện tại'
                  : (_period == 1 ? '3 tháng gần nhất' : '6 tháng gần nhất'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 12),

        // Chart area (placeholder or empty state)
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số bước', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: EmptyState(
                      icon: Icons.directions_walk_outlined,
                      title: 'Chưa có dữ liệu bước',
                      message:
                          'Kết nối Health Connect hoặc ghi bước chân để xem biểu đồ.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // small legend row (no data vs has data)
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text('Chưa đạt', style: theme.textTheme.bodySmall),
            const SizedBox(width: 16),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text('Đạt mục tiêu', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),

        // connect suggestion button (only when steps not connected)
        Builder(
          builder: (ctx) {
            final hc = ctx.watch<HealthConnectProvider>();
            if (hc.connectedSteps) return const SizedBox.shrink();
            return HealthConnectActionButton(
              text:
                  '👉 Kết nối Health Connect để tự động cập nhật bước chân mỗi ngày.',
              icon: Icons.directions_walk,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: ctx,
                  builder: (sheetCtx) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết nối Health Connect',
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cho phép Wao đồng bộ số bước hàng ngày từ thiết bị.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(sheetCtx).pop(),
                                child: const Text('Hủy'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(sheetCtx).pop();
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Chức năng kết nối chưa được triển khai ở bản demo.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Kết nối'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Steps statistics
        Text('Thống kê bước chân', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.directions_walk, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mục tiêu: 3,000 bước/ngày',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text('0', style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trung bình tuần này',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('0', style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trung bình tuần trước',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // day circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _DayCircle(label: 'T2', value: '-'),
                    _DayCircle(label: 'T3', value: '-'),
                    _DayCircle(label: 'T4', value: '-'),
                    _DayCircle(label: 'T5', value: '-'),
                    _DayCircle(label: 'T6', value: '-'),
                    _DayCircle(label: 'T7', value: '-'),
                    _DayCircle(label: 'CN', value: '-'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Activity level legend (colored badges)
        Text('Bước chân & mức độ hoạt động', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendBadge(
                  color: Colors.red.shade700,
                  label: 'ÍT VẬN ĐỘNG',
                  range: '< 3,000',
                ),
                const SizedBox(height: 8),
                _LegendBadge(
                  color: Colors.amber.shade700,
                  label: 'NHẸ NHÀNG',
                  range: '3,000 - 6,499',
                ),
                const SizedBox(height: 8),
                _LegendBadge(
                  color: Colors.blue.shade700,
                  label: 'TRUNG BÌNH',
                  range: '6,500 - 9,999',
                ),
                const SizedBox(height: 8),
                _LegendBadge(
                  color: Colors.green.shade700,
                  label: 'RẤT NĂNG ĐỘNG',
                  range: '10,000 - 12,499',
                ),
                const SizedBox(height: 8),
                _LegendBadge(
                  color: Colors.purple.shade700,
                  label: 'CỰC KỲ NĂNG ĐỘNG',
                  range: '> 12,500',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // bottom list tiles (adjust target / view log)
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Điều chỉnh mục tiêu'),
                subtitle: const Text('3,000 bước'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StepsTargetScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Nhật ký bước chân'),
                trailing: const Text(
                  'Xem lịch',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ActivityReportState extends State<ActivityReport> {
  // 0 = Tuần, 1 = Tháng, 2 = 6 Tháng
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedControl3(
                value: _period,
                onValueChanged: (v) => setState(() => _period = v),
                leftLabel: 'Tuần',
                middleLabel: 'Tháng',
                rightLabel: '6 Tháng',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            const SizedBox(width: 8),
            if (_period == 0)
              Text('Tuần hiện tại', style: theme.textTheme.bodyMedium)
            else if (_period == 1)
              Text('3 tháng gần nhất', style: theme.textTheme.bodyMedium)
            else
              Text('6 tháng gần nhất', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            child: Center(
              child: EmptyState(
                icon: Icons.fitness_center_outlined,
                title: 'Chưa có dữ liệu',
                message: 'Kết nối thiết bị hoặc ghi hoạt động để xem biểu đồ.',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Health Connect action button for Activity (uses steps connection state)
        Builder(
          builder: (ctx) {
            final hc = ctx.watch<HealthConnectProvider>();
            if (hc.connectedSteps) return const SizedBox.shrink();
            return HealthConnectActionButton(
              text: 'Kết nối Health Connect để tự động cập nhật hoạt động.',
              icon: Icons.fitness_center,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: ctx,
                  builder: (sheetCtx) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết nối Health Connect',
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cho phép Wao đồng bộ hoạt động và bước chân từ thiết bị.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(sheetCtx).pop(),
                                child: const Text('Hủy'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(sheetCtx).pop();
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Chức năng kết nối chưa được triển khai ở bản demo.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Kết nối'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Thống kê calo tập luyện', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mục tiêu tập luyện',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text('0 calo', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tổng calo tập luyện',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text('0 calo', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_period == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _DayCircle(label: 'T2', value: '0'),
                    _DayCircle(label: 'T3', value: '0'),
                    _DayCircle(label: 'T4', value: '0'),
                    _DayCircle(label: 'T5', value: '0'),
                    _DayCircle(label: 'T6', value: '0'),
                    _DayCircle(label: 'T7', value: '0'),
                    _DayCircle(label: 'CN', value: '0'),
                  ],
                )
              else if (_period == 1)
                _MonthBars(months: 3)
              else
                _MonthBars(months: 6),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text('Chưa ghi nhận', style: theme.textTheme.bodySmall),
            const SizedBox(width: 16),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text('Có dữ liệu ghi nhận', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "✨ Một tuần chưa có dữ liệu - thử dành 15 phút vận động mỗi ngày để làm nóng cơ thể lên nha.",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Xu hướng tập luyện của bạn', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calo tập luyện tuần này',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text('0 calo/tuần', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  'Calo tập luyện tuần trước',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text('0 calo/tuần', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💪 Chưa ghi nhận hoạt động. Bạn có thể vận động một chút để cải thiện xu hướng tập luyện nhé.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Nhật ký tập luyện'),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// top-level helper to build the nutrition chart widget. Kept as a file-private
// function so it can be used by NutritionReport without needing an instance.
Widget _nutritionChartWidget({
  required bool isWeek,
  required bool hasDiary,
  required BuildContext context,
  required List<double> daily,
  required List<double> proteinDaily,
  required List<double> carbDaily,
  required List<double> fatDaily,
  required double targetPerDay,
  required double weeklyTotal,
  required DateTime start,
  required DateTime selectedDate,
}) {
  final theme = Theme.of(context);
  if (isWeek) {
    if (hasDiary) {
      return LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: ([
            (weeklyTotal / 7.0) * 1.5,
            2000.0,
          ].reduce((a, b) => a > b ? a : b)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const names = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  final idx = value.toInt();
                  if (idx >= 0 && idx < names.length) {
                    return Text(names[idx], style: theme.textTheme.bodySmall);
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 28,
                interval: 1,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 300),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (i) => FlSpot(i.toDouble(), daily[i])),
              isCurved: true,
              barWidth: 3,
              color: Colors.purple,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.purple.withAlpha((0.12 * 255).round()),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (targetPerDay > 0)
                HorizontalLine(
                  y: targetPerDay,
                  color: Colors.purple,
                  strokeWidth: 1.5,
                  dashArray: [5, 5],
                ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: 'Chưa có bữa ăn',
        message: 'Ghi bữa ăn trong tuần để biểu đồ hiển thị dữ liệu thực tế.',
      ),
    );
  }

  // day view
  int sel = selectedDate.toUtc().difference(start).inDays;
  if (sel < 0 || sel > 6) sel = 6;
  final selFoodKcal = daily[sel];
  final selProtein = proteinDaily[sel];
  final selCarb = carbDaily[sel];
  final selFat = fatDaily[sel];
  final burned = 0.0;
  final realCalories = selFoodKcal - burned;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calo thực phẩm nạp vào', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(fmtCalories(selFoodKcal), style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calo tập luyện', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(fmtCalories(burned), style: theme.textTheme.bodyLarge),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Calo thực', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  fmtCalories(realCalories),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Protein'),
                const SizedBox(height: 6),
                Text(fmtGrams(selProtein)),
              ],
            ),
            Column(
              children: [
                Text('Carb'),
                const SizedBox(height: 6),
                Text(fmtGrams(selCarb)),
              ],
            ),
            Column(
              children: [
                Text('Fat'),
                const SizedBox(height: 6),
                Text(fmtGrams(selFat)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _DayCircle extends StatelessWidget {
  final String label;
  final String value;
  const _DayCircle({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class NutritionReport extends StatefulWidget {
  const NutritionReport({super.key});

  @override
  State<NutritionReport> createState() => _NutritionReportState();
}

class _NutritionReportState extends State<NutritionReport> {
  bool isWeek = true;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;
    final foodsProv = context.watch<FoodsProvider>();
    final diary = foodsProv.diary; // List<Map<String, dynamic>>

    // compute last-7-days daily totals (index 0..6 -> oldest..today)
    final today = DateTime.now().toUtc();
    final start = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final daily = List<double>.filled(7, 0.0);
    final proteinDaily = List<double>.filled(7, 0.0);
    final carbDaily = List<double>.filled(7, 0.0);
    final fatDaily = List<double>.filled(7, 0.0);
    double weeklyTotal = 0.0;
    double proteinTotal = 0.0, carbTotal = 0.0, fatTotal = 0.0;

    for (final e in diary) {
      final time = (e['time'] as DateTime).toUtc();
      if (time.isBefore(start)) continue;
      final idx = time.difference(start).inDays.clamp(0, 6);
      final kcal = (e['kcal'] as num).toDouble();
      daily[idx] += kcal;
      weeklyTotal += kcal;

      // attempt to compute macros if foodId available
      final fid = e['foodId'] as String?;
      final grams = (e['grams'] as num?)?.toDouble() ?? 0.0;
      if (fid != null) {
        final matches = foodsProv.items.where((f) => f.id == fid).toList();
        if (matches.isNotEmpty) {
          final food = matches.first;
          final factor = grams / 100.0;
          try {
            final p = (food.proteinG);
            final c = (food.carbG);
            final f = (food.fatG);
            proteinTotal += p * factor;
            carbTotal += c * factor;
            fatTotal += f * factor;
            proteinDaily[idx] += p * factor;
            carbDaily[idx] += c * factor;
            fatDaily[idx] += f * factor;
          } catch (_) {}
        }
      }
    }

    final hasDiary = weeklyTotal > 0.0;
    final dailyAvg = weeklyTotal / 7.0;
    final targetPerDay = (profile.calorieTarget ?? 0).toDouble();
    final targetPerWeek = targetPerDay * 7.0;
    // selected day index within the computed week (0..6) is computed when needed for day view

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Segmented control (Tuần / Ngày)
        Row(
          children: [
            Expanded(
              child: SegmentedControl<bool>(
                value: isWeek,
                onValueChanged: (v) => setState(() => isWeek = v),
                leftLabel: 'Tuần',
                rightLabel: 'Ngày',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Date range / day-strip selector
        if (isWeek)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
              ),
              const SizedBox(width: 8),
              Text(
                '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')} - ${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          )
        else
          _DaySelector(
            startDate: start,
            selected: _selectedDate,
            onDateSelected: (d) => setState(() => _selectedDate = d),
          ),

        const SizedBox(height: 12),

        // Chart placeholder
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWeek
                      ? 'Thống kê lượng calo trung bình'
                      : 'Thống kê lượng calo trong ngày',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8.0,
                      ),
                      child: _nutritionChartWidget(
                        isWeek: isWeek,
                        hasDiary: hasDiary,
                        context: context,
                        daily: daily,
                        proteinDaily: proteinDaily,
                        carbDaily: carbDaily,
                        fatDaily: fatDaily,
                        targetPerDay: targetPerDay,
                        weeklyTotal: weeklyTotal,
                        start: start,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Summary rows (use real data when available)
        SummaryRow(
          label: 'Calo mục tiêu trong tuần',
          value: fmtCalories(targetPerWeek),
        ),
        const Divider(),
        SummaryRow(
          label: 'Calo mục tiêu / ngày',
          value: fmtCalories(targetPerDay),
        ),
        const Divider(),
        SummaryRow(
          label: 'Calo thực trong tuần',
          value: fmtCalories(weeklyTotal),
        ),
        const Divider(),
        SummaryRow(
          label: 'Calo thực TB / ngày',
          value: fmtCalories(dailyAvg),
          valueColor: Colors.deepPurple,
        ),

        const SizedBox(height: 16),

        // Macro chart + list
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thống kê lượng macro', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          // prefer macros from diary if available, otherwise parse from profile.goal if set
                          double pPct = 0.2, cPct = 0.5, fPct = 0.3;
                          if (profile.goal.startsWith('macros:')) {
                            final parts = profile.goal.split(':');
                            if (parts.length > 1) {
                              final nums = parts[1]
                                  .split('-')
                                  .map((s) => int.tryParse(s) ?? 0)
                                  .toList();
                              if (nums.length == 3) {
                                pPct = nums[0] / 100.0;
                                cPct = nums[1] / 100.0;
                                fPct = nums[2] / 100.0;
                              }
                            }
                          } else if (weeklyTotal > 0) {
                            final macroKcal =
                                proteinTotal * 4 + carbTotal * 4 + fatTotal * 9;
                            if (macroKcal > 0) {
                              pPct = (proteinTotal * 4) / macroKcal;
                              cPct = (carbTotal * 4) / macroKcal;
                              fPct = (fatTotal * 9) / macroKcal;
                            }
                          }

                          final sections = [
                            PieChartSectionData(
                              value: pPct * 100,
                              title: '${(pPct * 100).round()}%',
                              color: Colors.orange,
                              radius: 36,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: cPct * 100,
                              title: '${(cPct * 100).round()}%',
                              color: Colors.blue,
                              radius: 40,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: fPct * 100,
                              title: '${(fPct * 100).round()}%',
                              color: Colors.teal,
                              radius: 36,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ];
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 24,
                              sections: sections,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // legend
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _LegendRow(color: Colors.orange, label: 'Chất đạm'),
                        SizedBox(height: 6),
                        _LegendRow(color: Colors.blue, label: 'Đường bột'),
                        SizedBox(height: 6),
                        _LegendRow(color: Colors.teal, label: 'Chất béo'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              MacroRow(
                icon: Icons.bolt,
                name: 'Chất đạm',
                grams: fmtGrams((proteinTotal > 0 ? proteinTotal / 7.0 : null)),
                pct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[0]) ??
                          0
                    : (proteinTotal > 0
                          ? ((proteinTotal * 4) /
                                    (proteinTotal * 4 +
                                        carbTotal * 4 +
                                        fatTotal * 9) *
                                    100)
                                .round()
                          : 0)),
                goalPct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[0]) ??
                          20
                    : 20),
              ),
              const SizedBox(height: 8),
              MacroRow(
                icon: Icons.rice_bowl,
                name: 'Đường bột',
                grams: fmtGrams((carbTotal > 0 ? carbTotal / 7.0 : null)),
                pct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[1]) ??
                          0
                    : (carbTotal > 0
                          ? ((carbTotal * 4) /
                                    (proteinTotal * 4 +
                                        carbTotal * 4 +
                                        fatTotal * 9) *
                                    100)
                                .round()
                          : 0)),
                goalPct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[1]) ??
                          50
                    : 50),
              ),
              const SizedBox(height: 8),
              MacroRow(
                icon: Icons.opacity,
                name: 'Chất béo',
                grams: fmtGrams((fatTotal > 0 ? fatTotal / 7.0 : null)),
                pct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[2]) ??
                          0
                    : (fatTotal > 0
                          ? ((fatTotal * 9) /
                                    (proteinTotal * 4 +
                                        carbTotal * 4 +
                                        fatTotal * 9) *
                                    100)
                                .round()
                          : 0)),
                goalPct: (profile.goal.startsWith('macros:')
                    ? int.tryParse(profile.goal.split(':')[1].split('-')[2]) ??
                          30
                    : 30),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Nutrition details
        Text('Giá trị dinh dưỡng / ngày', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        NutritionDetailRow(
          name: 'Đường bột (carb)',
          amountLeft: '--',
          amountTotal: '1.533 g',
        ),
        NutritionDetailRow(
          name: 'Chất xơ',
          amountLeft: '-',
          amountTotal: '175 g',
        ),
        NutritionDetailRow(
          name: 'Đường',
          amountLeft: '-',
          amountTotal: '308 g',
        ),
        const SizedBox(height: 8),
        NutritionDetailRow(
          name: 'Chất béo (fat)',
          amountLeft: '--',
          amountTotal: '406 g',
        ),
        NutritionDetailRow(
          name: 'Chất đạm (protein)',
          amountLeft: '--',
          amountTotal: '616 g',
        ),
        NutritionDetailRow(name: 'Muối', amountLeft: '--', amountTotal: '35 g'),
        const SizedBox(height: 12),
        Text('Khoáng chất', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        NutritionDetailRow(
          name: 'Canxi',
          amountLeft: '-',
          amountTotal: '5.600 mg',
        ),
        NutritionDetailRow(
          name: 'Kali',
          amountLeft: '-',
          amountTotal: '28.000 mg',
        ),
        NutritionDetailRow(
          name: 'Sắt',
          amountLeft: '-',
          amountTotal: '55,3 mg',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class SegmentedControl<T> extends StatelessWidget {
  final T value;
  final ValueChanged<T> onValueChanged;
  final String leftLabel;
  final String rightLabel;

  const SegmentedControl({
    required this.value,
    required this.onValueChanged,
    required this.leftLabel,
    required this.rightLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = value == true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(true as T),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isLeft ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    leftLabel,
                    style: TextStyle(
                      color: isLeft ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(false as T),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isLeft ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    rightLabel,
                    style: TextStyle(
                      color: !isLeft ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple 3-option segmented control used by ActivityReport (Tuần / Tháng / 6 Tháng)
class SegmentedControl3 extends StatelessWidget {
  final int value;
  final ValueChanged<int> onValueChanged;
  final String leftLabel;
  final String middleLabel;
  final String rightLabel;

  const SegmentedControl3({
    required this.value,
    required this.onValueChanged,
    required this.leftLabel,
    required this.middleLabel,
    required this.rightLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: value == 0 ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    leftLabel,
                    style: TextStyle(
                      color: value == 0 ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: value == 1 ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    middleLabel,
                    style: TextStyle(
                      color: value == 1 ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: value == 2 ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    rightLabel,
                    style: TextStyle(
                      color: value == 2 ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small bar chart-like row that shows `months` number of month labels and placeholder bars.
class _MonthBars extends StatelessWidget {
  final int months;
  const _MonthBars({required this.months});

  List<String> _labels(int months) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final d = DateTime(now.year, now.month - (months - 1 - i));
      return 'Thg${d.month}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labels(months);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((l) {
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(l, style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MacroRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String grams;
  final int pct;
  final int goalPct;

  const MacroRow({
    required this.icon,
    required this.name,
    required this.grams,
    required this.pct,
    required this.goalPct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orangeAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name ($grams)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: pct / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$pct%', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(width: 12),
                  Text(
                    '$goalPct%',
                    style: const TextStyle(color: Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NutritionDetailRow extends StatelessWidget {
  final String name;
  final String amountLeft;
  final String amountTotal;
  const NutritionDetailRow({
    required this.name,
    required this.amountLeft,
    required this.amountTotal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Text(amountLeft, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 16),
          Text(
            amountTotal,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DaySelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime selected;
  final ValueChanged<DateTime> onDateSelected;

  const _DaySelector({
    required this.startDate,
    required this.selected,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = List.generate(7, (i) => startDate.add(Duration(days: i)));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((d) {
          final isSel =
              d.year == selected.year &&
              d.month == selected.month &&
              d.day == selected.day;
          final weekday = [
            'T2',
            'T3',
            'T4',
            'T5',
            'T6',
            'T7',
            'CN',
          ][d.weekday - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () => onDateSelected(d),
              child: Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSel ? Colors.deepPurple : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSel ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.day.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSel ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  const _LegendBadge({
    required this.color,
    required this.label,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 86,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(range, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
