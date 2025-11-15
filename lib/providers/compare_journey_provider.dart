import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Provider that manages before/after journey images.
///
/// Images are stored in the app documents directory and the saved paths are
/// persisted with SharedPreferences so they survive app restarts.
class CompareJourneyProvider extends ChangeNotifier {
  static const _kLeftKey = 'compare_left_path';
  static const _kRightKey = 'compare_right_path';
  static const _kHistoryKey = 'compare_history_paths';

  String? _leftPath;
  String? _rightPath;

  String? get leftPath => _leftPath;
  String? get rightPath => _rightPath;

  bool get hasLeft => _leftPath != null && File(_leftPath!).existsSync();
  bool get hasRight => _rightPath != null && File(_rightPath!).existsSync();

  final ImagePicker _picker = ImagePicker();

  CompareJourneyProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    _leftPath = sp.getString(_kLeftKey);
    _rightPath = sp.getString(_kRightKey);
    notifyListeners();
  }

  Future<File?> _savePickedFile(XFile file, String filenameSuffix) async {
    try {
      final data = await file.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final target = File(
        '${dir.path}${Platform.pathSeparator}wao_compare_$filenameSuffix.jpg',
      );
      await target.writeAsBytes(data, flush: true);
      return target;
    } catch (e) {
      if (kDebugMode) print('Failed saving picked file: $e');
      return null;
    }
  }

  Future<void> pickLeft(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final saved = await _savePickedFile(picked, 'left');
    if (saved != null) {
      _leftPath = saved.path;
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kLeftKey, _leftPath!);
      notifyListeners();
    }
  }

  Future<void> pickRight(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final saved = await _savePickedFile(picked, 'right');
    if (saved != null) {
      _rightPath = saved.path;
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kRightKey, _rightPath!);
      notifyListeners();
    }
  }

  Future<void> clearLeft() async {
    if (_leftPath != null) {
      try {
        final f = File(_leftPath!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      _leftPath = null;
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kLeftKey);
      notifyListeners();
    }
  }

  Future<void> clearRight() async {
    if (_rightPath != null) {
      try {
        final f = File(_rightPath!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      _rightPath = null;
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kRightKey);
      notifyListeners();
    }
  }

  /// Return the existing files if available
  File? leftFile() => _leftPath == null ? null : File(_leftPath!);
  File? rightFile() => _rightPath == null ? null : File(_rightPath!);

  /// Create a side-by-side combined image from left and right and save to
  /// documents directory. Returns the saved File or null on failure.
  Future<File?> createCombinedImage({bool saveToHistory = true}) async {
    final left = leftFile();
    final right = rightFile();
    if (left == null || right == null) return null;
    try {
      final lBytes = await left.readAsBytes();
      final rBytes = await right.readAsBytes();

      final lCodec = await ui.instantiateImageCodec(lBytes);
      final lFrame = await lCodec.getNextFrame();
      final lImage = lFrame.image;

      final rCodec = await ui.instantiateImageCodec(rBytes);
      final rFrame = await rCodec.getNextFrame();
      final rImage = rFrame.image;

      final targetHeight = lImage.height > rImage.height
          ? lImage.height
          : rImage.height;
      final lScale = targetHeight / lImage.height;
      final rScale = targetHeight / rImage.height;
      final lWidth = (lImage.width * lScale).round();
      final rWidth = (rImage.width * rScale).round();

      final totalWidth = lWidth + rWidth;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint();

      // draw left image scaled
      final srcL = ui.Rect.fromLTWH(
        0,
        0,
        lImage.width.toDouble(),
        lImage.height.toDouble(),
      );
      final dstL = ui.Rect.fromLTWH(
        0,
        0,
        lWidth.toDouble(),
        targetHeight.toDouble(),
      );
      canvas.drawImageRect(lImage, srcL, dstL, paint);

      // draw right image scaled next to it
      final srcR = ui.Rect.fromLTWH(
        0,
        0,
        rImage.width.toDouble(),
        rImage.height.toDouble(),
      );
      final dstR = ui.Rect.fromLTWH(
        lWidth.toDouble(),
        0,
        rWidth.toDouble(),
        targetHeight.toDouble(),
      );
      canvas.drawImageRect(rImage, srcR, dstR, paint);

      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(totalWidth, targetHeight);
      final byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'wao_compare_combined_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(pngBytes, flush: true);

      if (saveToHistory) {
        final sp = await SharedPreferences.getInstance();
        final list = sp.getStringList(_kHistoryKey) ?? <String>[];
        list.insert(0, file.path);
        // keep history to a reasonable length
        if (list.length > 20) list.removeRange(20, list.length);
        await sp.setStringList(_kHistoryKey, list);
      }

      return file;
    } catch (e) {
      if (kDebugMode) print('createCombinedImage failed: $e');
      return null;
    }
  }

  /// Create a decorated combined image which includes a header with the
  /// current weight and a purple banner, then the side-by-side before/after
  /// images below. This is useful to share a single attractive image.
  Future<File?> createDecoratedCombinedImage({
    bool saveToHistory = true,
    double? startKg,
    double? currentKg,
    double? targetKg,
  }) async {
    final left = leftFile();
    final right = rightFile();
    if (left == null || right == null) return null;
    try {
      final lBytes = await left.readAsBytes();
      final rBytes = await right.readAsBytes();

      final lCodec = await ui.instantiateImageCodec(lBytes);
      final lFrame = await lCodec.getNextFrame();
      final lImage = lFrame.image;

      final rCodec = await ui.instantiateImageCodec(rBytes);
      final rFrame = await rCodec.getNextFrame();
      final rImage = rFrame.image;

      final photosHeight = lImage.height > rImage.height
          ? lImage.height
          : rImage.height;
      final lScale = photosHeight / lImage.height;
      final rScale = photosHeight / rImage.height;
      final lWidth = (lImage.width * lScale).round();
      final rWidth = (rImage.width * rScale).round();
      final photosWidth = lWidth + rWidth;

      // Header area height (in px)
      final headerHeight = 160;

      final totalWidth = photosWidth;
      final totalHeight = headerHeight + photosHeight;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint();

      // Draw header background
      final headerRect = ui.Rect.fromLTWH(
        0,
        0,
        totalWidth.toDouble(),
        headerHeight.toDouble(),
      );
      paint.color = const ui.Color(0xFF4B2B88);
      canvas.drawRect(headerRect, paint);

      // Draw a simple circular progress indicator on the left side of header
      final circleSize = 96.0;
      final circleCx = 36.0 + circleSize / 2;
      final circleCy = headerHeight / 2;
      final center = ui.Offset(circleCx, circleCy);
      final radius = circleSize / 2;

      // background circle
      final bgPaint = ui.Paint()..color = const ui.Color(0xFFD9D9F0);
      canvas.drawCircle(center, radius, bgPaint);

      // compute progress if possible
      double progress = 0.0;
      if (startKg != null &&
          currentKg != null &&
          targetKg != null &&
          (startKg - targetKg).abs() > 0.001) {
        // handle loss or gain generically
        if (startKg > targetKg) {
          // losing weight: progress = (start - current)/(start - target)
          progress = (startKg - currentKg) / (startKg - targetKg);
        } else {
          // gaining weight
          progress = (currentKg - startKg) / (targetKg - startKg);
        }
        progress = progress.clamp(0.0, 1.0);
      }

      // draw progress arc
      final arcPaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = ui.StrokeCap.round
        ..color = const ui.Color(0xFFFFD166);
      final rectForArc = ui.Rect.fromCircle(center: center, radius: radius - 6);
      canvas.drawArc(
        rectForArc,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        arcPaint,
      );

      // draw current weight text inside circle
      final currentText = currentKg != null
          ? '${currentKg.toStringAsFixed(1)} kg'
          : '-';
      final paragraphStyle = ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontWeight: ui.FontWeight.bold,
      );
      final pb = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(
          ui.TextStyle(color: const ui.Color(0xFF1F1726), fontSize: 14),
        )
        ..addText(currentText);
      final paragraph = pb.build()
        ..layout(ui.ParagraphConstraints(width: circleSize));
      canvas.drawParagraph(
        paragraph,
        ui.Offset(circleCx - circleSize / 2, circleCy - 10),
      );

      // Draw title and small labels to the right of circle
      final titlePb =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: ui.TextAlign.left,
                fontWeight: ui.FontWeight.bold,
              ),
            )
            ..pushStyle(ui.TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 20))
            ..addText('Hành trình cân nặng');
      final titleParagraph = titlePb.build()
        ..layout(
          ui.ParagraphConstraints(
            width: totalWidth - (circleCx + circleSize / 2) - 24,
          ),
        );
      canvas.drawParagraph(
        titleParagraph,
        ui.Offset(circleCx + circleSize / 2 + 12, circleCy - 28),
      );

      // small labels row
      final labels = [
        'Bắt đầu: ${startKg != null ? '${startKg.toStringAsFixed(1)} kg' : '-'}',
        'Hiện tại: ${currentKg != null ? '${currentKg.toStringAsFixed(1)} kg' : '-'}',
        'Mục tiêu: ${targetKg != null ? '${targetKg.toStringAsFixed(1)} kg' : '-'}',
      ];
      double labelY = circleCy + 6;
      double labelX = circleCx + circleSize / 2 + 12;
      for (var i = 0; i < labels.length; i++) {
        final lb =
            ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left))
              ..pushStyle(
                ui.TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 12),
              )
              ..addText(labels[i]);
        final p = lb.build()
          ..layout(ui.ParagraphConstraints(width: totalWidth - labelX - 12));
        canvas.drawParagraph(p, ui.Offset(labelX, labelY + i * 16));
      }

      // Draw the photos below the header
      // first draw left scaled
      final srcL = ui.Rect.fromLTWH(
        0,
        0,
        lImage.width.toDouble(),
        lImage.height.toDouble(),
      );
      final dstL = ui.Rect.fromLTWH(
        0,
        headerHeight.toDouble(),
        lWidth.toDouble(),
        photosHeight.toDouble(),
      );
      canvas.drawImageRect(lImage, srcL, dstL, ui.Paint());

      // draw right scaled next to it
      final srcR = ui.Rect.fromLTWH(
        0,
        0,
        rImage.width.toDouble(),
        rImage.height.toDouble(),
      );
      final dstR = ui.Rect.fromLTWH(
        lWidth.toDouble(),
        headerHeight.toDouble(),
        rWidth.toDouble(),
        photosHeight.toDouble(),
      );
      canvas.drawImageRect(rImage, srcR, dstR, ui.Paint());

      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(totalWidth, totalHeight);
      final byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'wao_compare_decorated_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(pngBytes, flush: true);

      if (saveToHistory) {
        final sp = await SharedPreferences.getInstance();
        final list = sp.getStringList(_kHistoryKey) ?? <String>[];
        list.insert(0, file.path);
        if (list.length > 20) list.removeRange(20, list.length);
        await sp.setStringList(_kHistoryKey, list);
      }

      return file;
    } catch (e) {
      if (kDebugMode) print('createDecoratedCombinedImage failed: $e');
      return null;
    }
  }

  /// Create a decorated image from a single photo. Uses the same header
  /// layout as [createDecoratedCombinedImage] but draws the single photo
  /// centered below the header.
  Future<File?> createDecoratedSingleImage(
    File photo, {
    bool saveToHistory = true,
    double? startKg,
    double? currentKg,
    double? targetKg,
  }) async {
    try {
      final pBytes = await photo.readAsBytes();

      final pCodec = await ui.instantiateImageCodec(pBytes);
      final pFrame = await pCodec.getNextFrame();
      final pImage = pFrame.image;

      final photosHeight = pImage.height;
      final pScale = 1.0;
      final pWidth = (pImage.width * pScale).round();

      // Header area height (in px)
      final headerHeight = 160;

      final totalWidth = pWidth;
      final totalHeight = headerHeight + photosHeight;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint();

      // Draw header background
      final headerRect = ui.Rect.fromLTWH(
        0,
        0,
        totalWidth.toDouble(),
        headerHeight.toDouble(),
      );
      paint.color = const ui.Color(0xFF4B2B88);
      canvas.drawRect(headerRect, paint);

      // Draw a simple circular progress area
      final circleSize = 96.0;
      final circleCx = 36.0 + circleSize / 2;
      final circleCy = headerHeight / 2;
      final center = ui.Offset(circleCx, circleCy);
      final radius = circleSize / 2;

      final bgPaint = ui.Paint()..color = const ui.Color(0xFFD9D9F0);
      canvas.drawCircle(center, radius, bgPaint);

      double progress = 0.0;
      if (startKg != null &&
          currentKg != null &&
          targetKg != null &&
          (startKg - targetKg).abs() > 0.001) {
        if (startKg > targetKg) {
          progress = (startKg - currentKg) / (startKg - targetKg);
        } else {
          progress = (currentKg - startKg) / (targetKg - startKg);
        }
        progress = progress.clamp(0.0, 1.0);
      }

      final arcPaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = ui.StrokeCap.round
        ..color = const ui.Color(0xFFFFD166);
      final rectForArc = ui.Rect.fromCircle(center: center, radius: radius - 6);
      canvas.drawArc(
        rectForArc,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        arcPaint,
      );

      final currentText = currentKg != null
          ? '${currentKg.toStringAsFixed(1)} kg'
          : '-';
      final paragraphStyle = ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontWeight: ui.FontWeight.bold,
      );
      final pb = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(
          ui.TextStyle(color: const ui.Color(0xFF1F1726), fontSize: 14),
        )
        ..addText(currentText);
      final paragraph = pb.build()
        ..layout(ui.ParagraphConstraints(width: circleSize));
      canvas.drawParagraph(
        paragraph,
        ui.Offset(circleCx - circleSize / 2, circleCy - 10),
      );

      final titlePb =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: ui.TextAlign.left,
                fontWeight: ui.FontWeight.bold,
              ),
            )
            ..pushStyle(ui.TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 20))
            ..addText('Hành trình cân nặng');
      final titleParagraph = titlePb.build()
        ..layout(
          ui.ParagraphConstraints(
            width: totalWidth - (circleCx + circleSize / 2) - 24,
          ),
        );
      canvas.drawParagraph(
        titleParagraph,
        ui.Offset(circleCx + circleSize / 2 + 12, circleCy - 28),
      );

      // Draw the single photo centered below the header
      final src = ui.Rect.fromLTWH(
        0,
        0,
        pImage.width.toDouble(),
        pImage.height.toDouble(),
      );
      final dst = ui.Rect.fromLTWH(
        0,
        headerHeight.toDouble(),
        pWidth.toDouble(),
        photosHeight.toDouble(),
      );
      canvas.drawImageRect(pImage, src, dst, ui.Paint());

      final picture = recorder.endRecording();
      final resultImage = await picture.toImage(totalWidth, totalHeight);
      final byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'wao_compare_decorated_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(pngBytes, flush: true);

      if (saveToHistory) {
        final sp = await SharedPreferences.getInstance();
        final list = sp.getStringList(_kHistoryKey) ?? <String>[];
        list.insert(0, file.path);
        if (list.length > 20) list.removeRange(20, list.length);
        await sp.setStringList(_kHistoryKey, list);
      }

      return file;
    } catch (e) {
      if (kDebugMode) print('createDecoratedSingleImage failed: $e');
      return null;
    }
  }

  Future<List<String>> getHistoryPaths() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kHistoryKey) ?? <String>[];
  }

  Future<void> removeHistoryEntry(String path) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final list = sp.getStringList(_kHistoryKey) ?? <String>[];
      list.removeWhere((p) => p == path);
      await sp.setStringList(_kHistoryKey, list);
      final f = File(path);
      if (await f.exists()) await f.delete();
      notifyListeners();
    } catch (_) {}
  }
}
