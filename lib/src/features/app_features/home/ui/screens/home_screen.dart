import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/activity_stats_card.dart';
import 'package:elfulk/src/core/widgets/app_error_card.dart';
import 'package:elfulk/src/core/widgets/app_loading_view.dart';
import 'package:elfulk/src/core/widgets/app_sheets.dart';
import 'package:elfulk/src/core/widgets/child_card.dart';
import 'package:elfulk/src/core/widgets/device_card.dart';
import 'package:elfulk/src/core/widgets/home_greeting_header.dart';
import 'package:elfulk/src/core/widgets/library_content_row.dart';
import 'package:elfulk/src/core/widgets/notification_card.dart';
import 'package:elfulk/src/core/widgets/app_confirmation_dialog.dart';
import 'package:elfulk/src/core/widgets/helpers/show_app_confirmation_dialog.dart';
import 'package:elfulk/src/core/widgets/section_header.dart';
import 'package:elfulk/src/features/app_features/home/data/models/dashboard_models.dart';
import 'package:elfulk/src/features/app_features/home/logic/dashboard_cubit/home_dashboard_cubit.dart';
import 'package:elfulk/src/features/app_features/notifications/data/models/notification_item.dart';
import 'package:elfulk/src/features/app_features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:elfulk/src/features/app_features/notifications/logic/notification_actions.dart';

/// الرئيسية الحقيقية للأب حسب التصميم (عربي RTL، داخل الـ shell).
///
/// ترويسة تحية بتبويبات داخلية (الكل/الاشعارات/اطفالي) و3 أجسام:
/// dashboard مركب، قائمة تنبيهات، قائمة أطفال. ترويسة الهاتف الترويجية
/// تظهر مرة واحدة في الجلسة (H5 ← H6).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  bool _upsellShown = false;

  static const List<HomeTabChip> _tabs = <HomeTabChip>[
    HomeTabChip(label: 'الكل', icon: Icons.grid_view_rounded),
    HomeTabChip(label: 'الاشعارات', icon: Icons.notifications_outlined),
    HomeTabChip(label: 'اطفالي', icon: Icons.people_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        return state.when(
          initial: () => const AppLoadingView(),
          loading: () => const AppLoadingView(),
          loaded: (HomeDashboard dashboard) {
            if (!_upsellShown) {
              _upsellShown = true;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _maybeShowUpsell(context),
              );
            }
            return _HomeLoaded(
              dashboard: dashboard,
              tab: _tab,
              onTab: (int i) => setState(() => _tab = i),
            );
          },
          error: (error) => AppErrorCard(
            message: error.detail,
            onRetry: () => context.read<HomeDashboardCubit>().load(),
          ),
        );
      },
    );
  }

  Future<void> _maybeShowUpsell(BuildContext context) async {
    if (!context.mounted) return;
    final bool? confirmed = await showAppConfirmationDialog(
      context: context,
      config: const AppConfirmationConfig(
        title: 'هل ترغب في اضافة رقم هاتفك',
        message: 'يمكنك اضافة رقم هاتفك من اجل توفير مستوى امني اعلى لحسابك.',
        icon: Icon(Icons.phone_android_outlined),
        primaryActionType: AppConfirmationPrimaryActionType.normal,
        primaryActionLabel: 'اضافة رقم الهاتف',
        secondaryActionLabel: 'تجاهل',
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final String? phone = await showAddPhoneSheet(
      context: context,
      title: 'هل ترغب في اضافة رقم هاتفك',
      hint: 'رقم الهاتف',
      saveLabel: 'حفظ التعديلات',
      prefixIcon: const Icon(Icons.phone_outlined),
    );
    if (phone != null && phone.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حفظ رقم الهاتف.')));
    }
  }
}

class _HomeLoaded extends StatelessWidget {
  final HomeDashboard dashboard;
  final int tab;
  final ValueChanged<int> onTab;

  const _HomeLoaded({
    required this.dashboard,
    required this.tab,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: context.spacing.pagePadding,
        children: [
          HomeGreetingHeader(
            title: dashboard.greetingTitle,
            subtitle: dashboard.greetingSubtitle,
            notificationCount: dashboard.notificationCount,
            onNotifications: () => context.push(Routes.notificationsScreen),
            tabs: _HomeScreenState._tabs,
            selectedTab: tab,
            onTabSelected: onTab,
          ),
          SizedBox(height: context.spacing.lg.h),
          if (tab == 0)
            _DashboardTab(dashboard: dashboard)
          else if (tab == 1)
            const _AlertsTab()
          else
            _ChildrenTab(children: dashboard.children),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final HomeDashboard dashboard;

  const _DashboardTab({required this.dashboard});

  /// أيقونة فئة النشاط حسب اسمها (بيانات dummy مؤقتة حتى يرسل
  /// الخادم مفاتيح الأيقونات في Phase 2).
  static IconData _categoryIcon(String label) {
    if (label.contains('الفيديو')) {
      return Icons.play_circle_outline_rounded;
    }
    if (label.contains('القصص')) {
      return Icons.menu_book_outlined;
    }
    return Icons.sports_esports_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (items, _) {
                final List<NotificationItem> alerts = items
                    .where((i) => i.category == NotificationCategory.alerts)
                    .toList();
                if (alerts.isEmpty) return const SizedBox.shrink();
                final NotificationItem first = alerts.first;
                return _NotificationCardAdapter(item: first);
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        SizedBox(height: context.spacing.md.h),
        const SectionHeader(title: 'قائمة الاطفال المرتبطين بحسابك'),
        SizedBox(height: context.spacing.sm.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final ChildProfile child in dashboard.children) ...[
                SizedBox(
                  width: 300.w,
                  child: _ChildCardAdapter(child: child),
                ),
                SizedBox(width: context.spacing.md.w),
              ],
            ],
          ),
        ),
        SizedBox(height: context.spacing.lg.h),
        ActivityStatsCard(
          title: dashboard.activityTitle,
          childLabel: dashboard.activityChildLabel,
          allowedLine: dashboard.allowedLine,
          remainingLine: dashboard.remainingLine,
          progress: dashboard.progress,
          progressStartLabel: dashboard.progressStartLabel,
          progressEndLabel: dashboard.progressEndLabel,
          categories: [
            for (final c in dashboard.categories)
              ActivityCategory(
                label: c.label,
                fraction: c.fraction,
                percentLabel: c.percentLabel,
                icon: _categoryIcon(c.label),
              ),
          ],
          actionLabel: dashboard.reportActionLabel,
          onAction: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('التقرير التفصيلي سيتوفر بعد ربط الخادم.'),
            ),
          ),
        ),
        SizedBox(height: context.spacing.lg.h),
        for (final LibrarySectionData section in dashboard.sections) ...[
          LibrarySection(
            title: section.title,
            childLabel: section.childLabel,
            rows: [
              for (final r in section.rows)
                LibraryContentRow(
                  title: r.title,
                  tags: r.tags,
                  badge: r.badge,
                  onTap: () => context.push(Routes.contentHubScreen),
                ),
            ],
            actionLabel: section.actionLabel,
            onAction: () => context.push(Routes.contentHubScreen),
          ),
          SizedBox(height: context.spacing.lg.h),
        ],
        const SectionHeader(title: 'قائمة الاجهزة المرتبطين بحسابك'),
        SizedBox(height: context.spacing.sm.h),
        for (final DeviceInfo device in dashboard.devices)
          DeviceCard(
            deviceName: device.deviceName,
            userName: device.userName,
            statusLabel: device.statusLabel,
            statusValue: device.statusValue,
            usageLabel: device.usageLabel,
            usageValue: device.usageValue,
            enrolledLabel: device.enrolledLabel,
            enrolledValue: device.enrolledValue,
          ),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (items, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items) ...[
                _NotificationCardAdapter(item: item),
                SizedBox(height: context.spacing.md.h),
              ],
            ],
          ),
          orElse: () => const AppLoadingView(),
        );
      },
    );
  }
}

class _ChildrenTab extends StatelessWidget {
  final List<ChildProfile> children;

  const _ChildrenTab({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'قائمة الاطفال المرتبطين بحسابك'),
        SizedBox(height: context.spacing.sm.h),
        for (final ChildProfile child in children) ...[
          _ChildCardAdapter(child: child),
          SizedBox(height: context.spacing.md.h),
        ],
        AddChildDashedCard(
          label: 'إضافة طفل جديد',
          onTap: () => context.push(Routes.addChildScreen),
        ),
      ],
    );
  }
}

/// بطاقة طفل مبنية من نموذج اللوحة (ألوان الإحصائيات هنا).
class _ChildCardAdapter extends StatelessWidget {
  final ChildProfile child;

  const _ChildCardAdapter({required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ChildCard(
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
    );
  }
}

/// بطاقة إشعار مبنية من عنصر notifications مع توجيه الإجراءات.
class _NotificationCardAdapter extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCardAdapter({required this.item});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      childLabel: item.childLabel,
      category: item.category,
      categoryLabel: item.categoryLabel,
      title: item.title,
      body: item.body,
      primaryLabel: item.primaryLabel,
      onPrimary: () => handleNotificationAction(
        context,
        context.read<NotificationsCubit>(),
        item,
        primary: true,
      ),
      secondaryLabel: item.secondaryLabel,
      onSecondary: item.secondaryLabel == null
          ? null
          : () => handleNotificationAction(
              context,
              context.read<NotificationsCubit>(),
              item,
              primary: false,
            ),
      onDismiss: () => context.read<NotificationsCubit>().dismiss(item.id),
    );
  }
}
