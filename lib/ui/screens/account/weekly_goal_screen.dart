import 'package:flutter/material.dart';

class WeeklyGoalScreen extends StatelessWidget {
  const WeeklyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mục tiêu hằng tuần')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Thiết lập mục tiêu hằng tuần - placeholder'),
            SizedBox(height: 12),
            Text(
              'Bạn có thể điều chỉnh số cân mục tiêu, chế độ tập luyện, hoặc mốc thời gian hoàn thành ở đây.',
            ),
          ],
        ),
      ),
    );
  }
}
