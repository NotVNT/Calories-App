import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cộng đồng')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Trang cộng đồng (placeholder). Bạn có thể đặt liên kết tới nhóm Facebook/Tiktok ở đây.',
          ),
        ),
      ),
    );
  }
}
