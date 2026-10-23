import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/activity_stats_card.dart';
import 'package:elfulk/src/core/widgets/app_filter_chip.dart';
import 'package:elfulk/src/core/widgets/section_header.dart';
import 'package:elfulk/src/core/widgets/settings_list_tile.dart';

/// لوحة الأنشطة (جذر تبويب مركز التحكم) حسب التصميم (عربي RTL).
///
/// رقاقات التاريخ + شبكة إحصائيات 2×2 + بطاقة الاستخدام + 3 بطاقات
/// مصغرة + ملخص الأسبوع. بيانات عرض ثابتة (تُغذى خادمياً Phase 2).
class ControlHomeScreen extends StatefulWidget {
  const ControlHomeScreen({super.key});

  @override
  State<ControlHomeScreen> createState() => _ControlHomeScreenState();
}

class _ControlHomeScreenState extends State<ControlHomeScreen> {
  int _dateIndex = 0;

  static const List<String> _dates = <String>[
    'اليوم',
    '15/07',
    '14/07',
    '13/07',
    '12/07',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: context.spacing.pagePadding,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'النشاط داخل المنصة',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: context.spacing.sm.w),
              Icon(
                Icons.people_outline_rounded,
                size: 24.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < _dates.length; i++) ...[
                  AppFilterChip(
                    label: _dates[i],
                    selected: i == _dateIndex,
                    onSelected: () => setState(() => _dateIndex = i),
                  ),
                  if (i < _dates.length - 1)
                    SizedBox(width: context.spacing.sm.w),
                ],
              ],
            ),
          ),
          SizedBox(height: context.spacing.md.h),
          const SectionHeader(title: 'إحصائيات الاستخدام'),
          SizedBox(height: context.spacing.sm.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: context.spacing.md.h,
            crossAxisSpacing: context.spacing.md.w,
            childAspectRatio: 1.2,
            children: const [
              _StatTile(
                icon: Icons.bolt_outlined,
                iconColor: Color(0xFF2E8C84),
                title: 'الحالة الحالية',
                value: 'نشط',
              ),
              _StatTile(
                icon: Icons.warning_amber_rounded,
                iconColor: Color(0xFFF03A3A),
                title: 'محاولات التجاوز',
                value: '0 محاولة',
              ),
              _StatTile(
                icon: Icons.play_circle_outline_rounded,
                iconColor: Color(0xFF2E8C84),
                title: 'عدد الجلسات',
                value: '4 جلسات',
              ),
              _StatTile(
                icon: Icons.hourglass_empty_rounded,
                iconColor: Color(0xFFF59E0B),
                title: 'متوسط فترات الراحة',
                value: '2 ساعات و 35 دقيقة',
              ),
            ],
          ),
          SizedBox(height: context.spacing.md.h),
          ActivityStatsCard(
            title: 'مقدار الاستخدام اليوم',
            leadingIcon: Icon(
              Icons.timer_outlined,
              size: 22.sp,
              color: theme.colorScheme.primary,
            ),
            onEdit: () => context.push(Routes.timeHubScreen),
            allowedLine: 'إجمالي المدة المسموحة: 2 ساعات و 30 دقائق.',
            remainingLine:
                'الوقت المتبقي من الإجمالي المدة المسموح بها هو: 45 دقيقة.',
            progress: 0.7,
            progressStartLabel: '0% من الوقت',
            progressEndLabel: '100% من الوقت',
            showDivider: true,
          ),
          SizedBox(height: context.spacing.md.h),
          Row(
            children: const [
              Expanded(
                child: _MiniCategory(
                  icon: Icons.play_circle_outline_rounded,
                  title: 'الفيديوهات',
                  percentLabel: '100% من الوقت',
                  fraction: 1.0,
                  barColor: Color(0xFFF03A3A),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniCategory(
                  icon: Icons.menu_book_outlined,
                  title: 'القصص',
                  percentLabel: '50% من الوقت',
                  fraction: 0.5,
                  barColor: Color(0xFF2E8C84),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniCategory(
                  icon: Icons.sports_esports_outlined,
                  title: 'الالعاب',
                  percentLabel: '20% من الوقت',
                  fraction: 0.2,
                  barColor: Color(0xFFF4AA08),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md.h),
          SettingsListTile(
            key: const ValueKey('control-rules-entry'),
            title: 'تخصيص القواعد',
            leading: const Icon(Icons.rule_folder_outlined),
            leadingBackgroundColor: theme.colorScheme.surfaceContainerHighest,
            trailing: const SettingsTileTrailing.chevron(),
            onTap: () => context.push(Routes.rulesHubScreen),
          ),
          SizedBox(height: context.spacing.md.h),
          const _WeekSummaryCard(),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية صغيرة متمركزة (أيقونة + عنوان + قيمة).
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.xl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.sp, color: iconColor),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة فئة مصغرة: أيقونة + عنوان + نسبة + شريط ملوّن.
class _MiniCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final String percentLabel;
  final double fraction;
  final Color barColor;

  const _MiniCategory({
    required this.icon,
    required this.title,
    required this.percentLabel,
    required this.fraction,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.xl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.sm.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: barColor),
            SizedBox(height: 2.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              percentLabel,
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 4.h),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: double.infinity,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.radius.full.r),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(
                          context.radius.full.r,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة ملخص الأسبوع (أيقونة تقويم + إجمالي متمركز + حبة الأسبوع).
class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.xxl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md.r),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.radius.lg.r),
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 22.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: context.spacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        context.radius.full.r,
                      ),
                    ),
                    child: Text(
                      'هذا الاسبوع',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '23 ساعة و 54 دقيقة',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'هو إجمالي الوقت المستهلك داخل المنصة',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
