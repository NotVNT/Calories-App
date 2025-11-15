import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/data/services/onboarding_logger.dart';
import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'gender_step_screen.dart';

class NicknameStepScreen extends ConsumerStatefulWidget {
  const NicknameStepScreen({super.key});

  @override
  ConsumerState<NicknameStepScreen> createState() => _NicknameStepScreenState();
}

class _NicknameStepScreenState extends ConsumerState<NicknameStepScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _isValid = false;
  DateTime? _stepStartTime;

  @override
  void initState() {
    super.initState();
    _stepStartTime = DateTime.now();
    final nickname = ref.read(onboardingControllerProvider).nickname ?? '';
    _controller = TextEditingController(text: nickname);
    _validateNickname(nickname, shouldSetState: false);
    // Track step view
    OnboardingLogger.logStepViewed(stepName: 'nickname', durationMs: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNicknameChanged(String value) {
    _validateNickname(value);
  }

  void _validateNickname(String value, {bool shouldSetState = true}) {
    final trimmed = value.trim();

    String? error;
    bool isValid = true;

    if (trimmed.isEmpty) {
      error = 'Vui lòng nhập nickname của bạn';
      isValid = false;
    } else if (trimmed.isEmpty || trimmed.length > 24) {
      error = 'Nickname phải từ 1 đến 24 ký tự';
      isValid = false;
    } else {
      final hasAlphaNumeric = RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(trimmed);
      if (!hasAlphaNumeric) {
        error = 'Nickname cần ít nhất một ký tự chữ hoặc số';
        isValid = false;
      }
    }

    if (shouldSetState) {
      setState(() {
        _errorText = error;
        _isValid = isValid;
      });
    } else {
      _errorText = error;
      _isValid = isValid;
    }
  }

  void _onContinuePressed() {
    final trimmed = _controller.text.trim();
    ref.read(onboardingControllerProvider.notifier).updateNickname(trimmed);
    FocusScope.of(context).unfocus();
    
    // Track step completion with duration
    if (_stepStartTime != null) {
      final duration = DateTime.now().difference(_stepStartTime!);
      OnboardingLogger.logStepViewed(
        stepName: 'gender',
        durationMs: duration.inMilliseconds,
      );
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GenderStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.palePink,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Bước 1/6'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: bottomPadding + 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn muốn chúng tôi gọi bạn là gì?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nickname sẽ được dùng xuyên suốt trong trải nghiệm Ăn Khỏe.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Progress
                const ProgressIndicatorWidget(
                  progress: 1 / OnboardingModel.totalSteps,
                ),
                const SizedBox(height: 32),

                // Input card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.charmingGreen.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onNicknameChanged,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.nearBlack,
                        ),
                        maxLength: 24,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          counterText: '',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.mintGreen,
                              width: 2,
                            ),
                          ),
                          hintText: 'Nickname',
                          hintStyle: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.nearBlack.withAlpha((0.4 * 255).round()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1-24 ký tự, không dùng toàn emoji. Bạn có thể thay đổi sau.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.nearBlack.withAlpha((0.7 * 255).round()),
                            ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorText!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValid ? _onContinuePressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isValid ? AppColors.mintGreen : AppColors.charmingGreen,
                      foregroundColor: AppColors.nearBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.nearBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


