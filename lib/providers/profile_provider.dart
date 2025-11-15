import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

/// ProfileProvider holds the current profile in memory and persists via
/// ProfileService. It supports both Firebase-backed operations and a local
/// in-memory fallback when Firebase is disabled.
class ProfileProvider extends ChangeNotifier {
  Profile _profile = const Profile(name: 'Người dùng');
  bool isLoading = false;
  bool isSaving = false;
  final String uid; // In a real app this is the firebase auth uid.
  final ProfileService _service;

  ProfileProvider({required this.uid, required ProfileService service})
    : _service = service;

  Profile get profile => _profile;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      final p = await _service.fetchProfile(uid);
      // Debug: log fetched profile to help diagnose missing data in UI
      try {
        debugPrint('[ProfileProvider] fetched profile for uid=$uid -> $p');
      } catch (_) {}
      _profile = p;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Profile p) async {
    isSaving = true;
    notifyListeners();
    try {
      final updated = await _service.updateProfile(uid, p);
      _profile = updated;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> uploadAvatarFromXFile(dynamic xfile) async {
    // xfile is expected to be XFile from image_picker; use the service to upload
    if (xfile == null) return;
    final url = await _service.uploadAvatar(uid, xfile);
    if (url != null) {
      _profile = _profile.copyWith(
        avatarUrl: url,
        updatedAt: DateTime.now().toUtc(),
      );
      await _service.updateProfile(uid, _profile);
      notifyListeners();
    }
  }

  /// Delete account data for this uid via the underlying service. Clears
  /// in-memory profile afterwards.
  Future<void> deleteAccount() async {
    try {
      await _service.deleteAccount(uid);
    } catch (e) {
      debugPrint('deleteAccount failed: $e');
    }
    _profile = const Profile(name: 'Người dùng');
    notifyListeners();
  }

  /// Change password for the current user via ProfileService. Returns true
  /// when the operation completes successfully.
  Future<bool> changePassword(String newPassword) async {
    try {
      final ok = await _service.changePassword(newPassword);
      return ok;
    } catch (e) {
      debugPrint('changePassword failed: $e');
      rethrow;
    }
  }

  /// Save a measurement (both history and latest) via ProfileService.
  Future<bool> saveMeasurement({
    required String type,
    required double value,
    String unit = 'kg',
    String? note,
    String? imageUrl,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      await _service.saveMeasurement(
        uid,
        type: type,
        value: value,
        unit: unit,
        note: note,
        imageUrl: imageUrl,
      );

      // Update in-memory measurements map so UI shows latest values
      final existing = Map<String, double>.from(_profile.measurements ?? {});
      existing[type] = value;

      // Start with base updated profile
      Profile updated = _profile.copyWith(
        measurements: existing,
        updatedAt: DateTime.now().toUtc(),
      );

      // Mirror common typed fields for convenience
      if (type.toLowerCase() == 'weight' ||
          type.toLowerCase().contains('cân nặng')) {
        updated = updated.copyWith(weightKg: value);
      } else if (type.toLowerCase() == 'height' ||
          type.toLowerCase().contains('chiều cao')) {
        updated = updated.copyWith(heightCm: value);
      }

      _profile = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('saveMeasurement failed: $e');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
    return true;
  }
}
