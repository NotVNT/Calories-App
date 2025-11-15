import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/firebase_service.dart';
import '../../../../providers/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetupSummaryScreen extends StatefulWidget {
  const SetupSummaryScreen({super.key});

  @override
  State<SetupSummaryScreen> createState() => _SetupSummaryScreenState();
}

class _SetupSummaryScreenState extends State<SetupSummaryScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final goalTitle = args['goalTitle'] as String? ?? '-';
    final weight = (args['weight'] as double?)?.toStringAsFixed(1) ?? '-';
    final activityLabel = args['activityLabel'] as String? ?? '-';

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
              value: 1.0,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(24),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wao tổng hợp lại thông tin giúp bạn nha',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎯 MỤC TIÊU', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(
                          goalTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '📍 CÂN NẶNG MỤC TIÊU',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$weight kg',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '🔥 CƯỜNG ĐỘ TẬP LUYỆN',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(activityLabel, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  // Illustration placeholder
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/setup_summary.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            const Center(child: Icon(Icons.person, size: 80)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // BMI bar placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // simple colored bar
                  SizedBox(
                    height: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.45,
                        color: Colors.green,
                        backgroundColor: Colors.redAccent.withAlpha(40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('<15'),
                      Text('18.5'),
                      Text('22.9'),
                      Text('24.9'),
                      Text('29.9'),
                      Text('>=35'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'BMI của bạn: 22.3',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
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
            const Spacer(),
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          // Persist the chosen setup into the user's profile and a merged field
                          setState(() => _saving = true);
                          final args =
                              ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>? ??
                              {};
                          final goalTitle = args['goalTitle'] as String? ?? '-';
                          final weight = args['weight'] as double?;
                          final activityLabel =
                              args['activityLabel'] as String? ?? '-';
                          final activityIndex = args['activityIndex'] as int?;

                          // capture scaffold messenger and navigator to avoid using
                          // BuildContext across async gaps
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          try {
                            // Update Profile via provider/service
                            final prov = Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            );
                            final current = prov.profile;
                            final updated = current.copyWith(
                              goal: goalTitle,
                              weightKg: weight ?? current.weightKg,
                              updatedAt: DateTime.now().toUtc(),
                            );
                            await prov.updateProfile(updated);

                            // Also write activity metadata as merged fields
                            try {
                              FirebaseService.ensureCanWrite();
                              final doc = FirebaseService.firestore
                                  .collection('users')
                                  .doc(prov.uid);
                              final map = <String, dynamic>{
                                'activityLabel': activityLabel,
                                'activityIndex': activityIndex,
                                'setupLast': DateTime.now()
                                    .toUtc()
                                    .toIso8601String(),
                              };
                              await doc.set(map, SetOptions(merge: true));
                            } catch (e) {
                              debugPrint(
                                'Failed to write activity metadata: $e',
                              );
                            }

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Lưu thiết lập thành công'),
                              ),
                            );
                            navigator.popUntil(
                              (route) =>
                                  route.settings.name == '/account' ||
                                  route.isFirst,
                            );
                          } catch (e) {
                            debugPrint('Save setup failed: $e');
                            messenger.showSnackBar(
                              SnackBar(content: Text('Lưu thất bại: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _saving
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Tiếp tục'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
