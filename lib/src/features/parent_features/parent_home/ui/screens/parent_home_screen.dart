import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/app_error_card.dart';
import 'package:elfulk/src/core/widgets/app_loading_view.dart';
import 'package:elfulk/src/core/widgets/child_card.dart';
import 'package:elfulk/src/core/widgets/section_header.dart';
import 'package:elfulk/src/features/app_features/home/data/models/dashboard_models.dart';
import 'package:elfulk/src/features/app_features/home/logic/dashboard_cubit/home_dashboard_cubit.dart';

/// قائمة الأطفال المرتبطين (H1) حسب التصميم (عربي RTL، داخل الـ shell).
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        return state.when(
          initial: () => const AppLoadingView(),
          loading: () => const AppLoadingView(),
          loaded: (HomeDashboard dashboard) =>
              _ParentLoadedView(dashboard: dashboard),
          error: (error) => AppErrorCard(
            message: error.detail,
            onRetry: () => context.read<HomeDashboardCubit>().load(),
          ),
        );
      },
    );
  }
}

class _ParentLoadedView extends StatelessWidget {
  final HomeDashboard dashboard;

  const _ParentLoadedView({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: context.spacing.pagePadding,
        children: [
          const SectionHeader(title: 'قائمة الاطفال المرتبطين بحسابك'),
          SizedBox(height: context.spacing.sm.h),
          for (final ChildProfile child in dashboard.children) ...[
            ChildCard(
              name: child.name,
              usagePrefix: child.usagePrefix,
              usageValue: child.usageValue,
              stats: [
                ChildStat(
                  label: child.ageLabel,
                  value: child.ageValue,
                  valueColor: theme.colorScheme.primary,
                ),
                ChildStat(label: child.genderLabel, value: child.genderValue),
                ChildStat(
                  label: child.alertsLabel,
                  value: child.alertsValue,
                  valueColor: const Color(0xFFF59E0B),
                ),
              ],
              actionLabel: 'الانتقال إلى وجهته الخاصة',
              onAction: () => context.push(Routes.childHomeScreen),
              onMenu: () => context.push(Routes.parentKidsScreen),
            ),
            SizedBox(height: context.spacing.md.h),
          ],
          AddChildDashedCard(
            label: 'إضافة طفل جديد',
            onTap: () => context.push(Routes.addChildScreen),
          ),
        ],
      ),
    );
  }
}
