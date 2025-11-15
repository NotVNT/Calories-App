import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;
import '../../providers/profile_provider.dart';
import '../../models/profile.dart';

/// AvatarCircle now supports both a direct-callback API (used by the
/// migrated account screen) and a legacy provider-backed fallback.
class AvatarCircle extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final Future<void> Function(XFile?)? onAvatarPicked;
  final Future<void> Function(String)? onUrlSubmitted;
  final Future<void> Function()? onClear;

  const AvatarCircle({
    super.key,
    this.size = 96.0,
    this.avatarUrl,
    this.onAvatarPicked,
    this.onUrlSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    Profile? profile;
    try {
      profile = context.watch<ProfileProvider>().profile;
    } catch (_) {
      profile = null;
    }

    final String? url = avatarUrl ?? profile?.avatarUrl;

    Widget avatarChild;
    if (url != null && url.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _initialsCircle(profile, size);
          },
        ),
      );
    } else {
      avatarChild = _initialsCircle(profile, size);
    }

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: avatarChild,
      ),
    );
  }

  Widget _initialsCircle(Profile? profile, double size) {
    final name = profile?.name ?? '';
    final initials = (name.isNotEmpty)
        ? name
              .trim()
              .split(' ')
              .map((s) => s.isNotEmpty ? s[0] : '')
              .take(2)
              .join()
        : 'U';
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(fontSize: size / 3, color: Colors.white),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final TextEditingController ctrl = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chọn ảnh đại diện',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final provider = (() {
                    try {
                      return context.read<ProfileProvider>();
                    } catch (_) {
                      return null;
                    }
                  })();
                  final picker = ImagePicker();
                  final XFile? picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    if (onAvatarPicked != null) {
                      await onAvatarPicked!(picked);
                    } else {
                      try {
                        provider?.uploadAvatarFromXFile(picked);
                      } catch (_) {}
                    }
                  }
                  navigator.pop();
                },
                child: const Text('Chọn từ thư viện'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final provider = (() {
                    try {
                      return context.read<ProfileProvider>();
                    } catch (_) {
                      return null;
                    }
                  })();
                  final picker = ImagePicker();
                  final XFile? picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    if (onAvatarPicked != null) {
                      await onAvatarPicked!(picked);
                    } else {
                      try {
                        provider?.uploadAvatarFromXFile(picked);
                      } catch (_) {}
                    }
                  }
                  navigator.pop();
                },
                child: const Text('Chụp ảnh'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Đường dẫn ảnh (URL hoặc file)',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final provider = (() {
                    try {
                      return context.read<ProfileProvider>();
                    } catch (_) {
                      return null;
                    }
                  })();
                  final path = ctrl.text.trim();
                  if (path.isNotEmpty) {
                    if (onUrlSubmitted != null) {
                      await onUrlSubmitted!(path);
                    } else {
                      try {
                        final p = provider;
                        if (p != null) {
                          p.updateProfile(
                            p.profile.copyWith(
                              avatarUrl: path,
                              updatedAt: DateTime.now().toUtc(),
                            ),
                          );
                        }
                      } catch (_) {}
                    }
                  }
                  navigator.pop();
                },
                child: const Text('Sử dụng đường dẫn'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final provider = (() {
                    try {
                      return context.read<ProfileProvider>();
                    } catch (_) {
                      return null;
                    }
                  })();
                  if (onClear != null) {
                    await onClear!();
                  } else {
                    try {
                      final p = provider;
                      if (p != null) {
                        p.updateProfile(
                          p.profile.copyWith(
                            avatarUrl: null,
                            updatedAt: DateTime.now().toUtc(),
                          ),
                        );
                      }
                    } catch (_) {}
                  }
                  navigator.pop();
                },
                child: const Text('Xóa ảnh'),
              ),
            ],
          ),
        );
      },
    );
  }
}
