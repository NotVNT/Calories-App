import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calories_app/core/theme/app_colors.dart';
import 'package:calories_app/features/meals/domain/meal_plan.dart';
import 'package:calories_app/features/meals/presentation/providers/meals_providers.dart';
import 'package:calories_app/features/meals/presentation/widgets/meal_category_chip.dart';
import 'package:calories_app/features/meals/presentation/widgets/meal_plan_card.dart';

class MealsRootPage extends ConsumerStatefulWidget {
  const MealsRootPage({super.key});

  @override
  ConsumerState<MealsRootPage> createState() => _MealsRootPageState();
}

class _MealsRootPageState extends ConsumerState<MealsRootPage> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.palePink,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MealsHeader(
                  onSearchTap: () {
                    // TODO: Navigate to meal plan search page.
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.nearBlack,
                    unselectedLabelColor: AppColors.mediumGray,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    tabs: [
                      Tab(text: 'Thực đơn của bạn'),
                      Tab(text: 'Khám phá thực đơn'),
                      Tab(text: 'Thực đơn tự tạo'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _MealPlanListView(
                      plansBuilder: (ref) => ref.watch(userMealPlansProvider),
                      emptyLabel:
                          'Bạn chưa có thực đơn nào. Hãy khám phá và lưu lại kế hoạch phù hợp!',
                      showStartButton: true,
                    ),
                    _ExploreMealsView(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (index) {
                        setState(() => _selectedCategory = index);
                      },
                    ),
                    _MealPlanListView(
                      plansBuilder: (ref) => ref.watch(customMealPlansProvider),
                      emptyLabel:
                          'Bắt đầu sáng tạo thực đơn riêng, lưu lại món yêu thích theo khẩu vị của bạn.',
                      showStartButton: false,
                      actionButtonBuilder: (context) => OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to create meal plan flow.
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tạo thực đơn mới'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.nearBlack,
                          side: const BorderSide(color: AppColors.charmingGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealsHeader extends StatelessWidget {
  const _MealsHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final greeting = _greetingText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.mediumGray,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Thực đơn hôm nay',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.nearBlack,
              ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onSearchTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withAlpha((0.25 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Tìm thực đơn theo mục tiêu hoặc món ăn bạn thích...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                  ),
                ),
                const Icon(
                  Icons.tune,
                  color: AppColors.nearBlack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 17) return 'Buổi chiều năng động';
    return 'Buổi tối thư giãn';
  }
}

class _MealPlanListView extends ConsumerWidget {
  const _MealPlanListView({
    required this.plansBuilder,
    required this.emptyLabel,
    this.showStartButton = true,
    this.actionButtonBuilder,
  });

  final List<MealPlan> Function(WidgetRef ref) plansBuilder;
  final String emptyLabel;
  final bool showStartButton;
  final WidgetBuilder? actionButtonBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = plansBuilder(ref);

    if (plans.isEmpty) {
      return _EmptyState(
        message: emptyLabel,
        action: actionButtonBuilder?.call(context),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return MealPlanCard(
          plan: plan,
          showStartButton: showStartButton,
        );
      },
    );
  }
}

class _ExploreMealsView extends ConsumerWidget {
  const _ExploreMealsView({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final int selectedCategory;
  final ValueChanged<int> onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(mealCategoriesProvider);
    final plans = ref.watch(exploreMealPlansProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn mục tiêu dinh dưỡng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () => onCategoryChanged(index),
                        child: MealCategoryChip(
                          category: category,
                          isSelected: index == selectedCategory,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Thực đơn đề xuất',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          sliver: SliverList.separated(
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return MealPlanCard(plan: plan);
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.action,
  });

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withAlpha((0.25 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mediumGray,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}


