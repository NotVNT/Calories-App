import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/core/theme/theme.dart';

import 'package:calories_app/features/onboarding/domain/onboarding_model.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/progress_indicator_widget.dart';
import 'height_step_screen.dart';

class DobStepScreen extends ConsumerStatefulWidget {
  const DobStepScreen({super.key});

  @override
  ConsumerState<DobStepScreen> createState() => _DobStepScreenState();
}

class _DobStepScreenState extends ConsumerState<DobStepScreen> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late List<int> _years;

  int _calculatedAge = 0;
  bool _isValid = false;
  String? _warningText;

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingControllerProvider);
    final initialDate = _initialDate(onboardingState);
    _years = _generateYears(initialDate.year);

    _selectedYear = initialDate.year;
    _selectedMonth = initialDate.month;
    _selectedDay = initialDate.day;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: _years.indexOf(_selectedYear));

    _recalculateAge();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime _initialDate(OnboardingModel state) {
    final now = DateTime.now();
    final fallback = DateTime(now.year - 25, now.month, now.day);
    if (state.dobIso != null) {
      final parsed = DateTime.tryParse(state.dobIso!);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  List<int> _generateYears(int initialYear) {
    final currentYear = DateTime.now().year;
    final minYear = currentYear - 110; // allow up to 110 years old
    final maxYear = currentYear; // future dates will be invalidated
    final span = maxYear - minYear + 1;
    final years = List<int>.generate(span, (index) => maxYear - index);
    if (!years.contains(initialYear)) {
      years.add(initialYear);
      years.sort((a, b) => b.compareTo(a));
    }
    return years;
  }

  int _daysInMonth(int year, int month) {
    return DateUtils.getDaysInMonth(year, month);
  }

  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  void _onDayChanged(int index) {
    setState(() {
      _selectedDay = index + 1;
      _recalculateAge();
    });
  }

  void _onMonthChanged(int index) {
    setState(() {
      _selectedMonth = index + 1;
      _normalizeDay();
      _recalculateAge();
    });
  }

  void _onYearChanged(int index) {
    setState(() {
      _selectedYear = _years[index];
      _normalizeDay();
      _recalculateAge();
    });
  }

  void _normalizeDay() {
    final maxDay = _daysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _dayController.jumpToItem(maxDay - 1);
        }
      });
    }
  }

  void _recalculateAge() {
    final today = DateTime.now();
    final dob = _selectedDate;

    int age = today.year - dob.year;
    final hasNotHadBirthday =
        today.month < dob.month || (today.month == dob.month && today.day < dob.day);
    if (hasNotHadBirthday) {
      age--;
    }

    String? warning;
    bool isValid = true;

    if (dob.isAfter(today)) {
      warning = 'Ngày sinh không thể ở tương lai';
      isValid = false;
    } else if (age < 10) {
      warning = 'Ăn Khỏe dành cho người từ 10 tuổi trở lên';
      isValid = false;
    } else if (age > 100) {
      warning = 'Vui lòng kiểm tra lại. Tuổi tối đa được hỗ trợ là 100';
      isValid = false;
    }

    _calculatedAge = age;
    _warningText = warning;
    _isValid = isValid;
  }

  void _onContinuePressed() {
    if (!_isValid) return;

    ref.read(onboardingControllerProvider.notifier).updateDob(_selectedDate);

    // Navigate to height step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HeightStepScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth(_selectedYear, _selectedMonth);

    return Scaffold(
      backgroundColor: AppColors.palePink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bước 3/6'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Ngày sinh của bạn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chúng tôi sẽ tính tuổi của bạn tự động dựa trên ngày sinh.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              ProgressIndicatorWidget(
                progress: 3 / OnboardingModel.totalSteps,
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPicker(
                              controller: _dayController,
                              itemCount: daysInMonth,
                              labelBuilder: (index) => index + 1,
                              onSelectedItemChanged: _onDayChanged,
                              heading: 'Ngày',
                            ),
                          ),
                          Expanded(
                            child: _buildPicker(
                              controller: _monthController,
                              itemCount: 12,
                              labelBuilder: (index) => index + 1,
                              onSelectedItemChanged: _onMonthChanged,
                              heading: 'Tháng',
                            ),
                          ),
                          Expanded(
                            child: _buildPicker(
                              controller: _yearController,
                              itemCount: _years.length,
                              labelBuilder: (index) => _years[index],
                              onSelectedItemChanged: _onYearChanged,
                              heading: 'Năm',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tuổi hiện tại: ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '$_calculatedAge',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.nearBlack,
                              ),
                        ),
                      ],
                    ),
                    if (_warningText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _warningText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int Function(int index) labelBuilder,
    required ValueChanged<int> onSelectedItemChanged,
    required String heading,
  }) {
    return Column(
      children: [
        Text(
          heading,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.mediumGray,
              ),
        ),
        const SizedBox(height: 8),
        Expanded(
            child: CupertinoPicker.builder(
            scrollController: controller,
            itemExtent: 44,
            magnification: 1.08,
            useMagnifier: true,
            onSelectedItemChanged: onSelectedItemChanged,
            selectionOverlay: Container(
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            childCount: itemCount,
            itemBuilder: (context, index) {
              final value = labelBuilder(index);
              return Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.nearBlack,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

