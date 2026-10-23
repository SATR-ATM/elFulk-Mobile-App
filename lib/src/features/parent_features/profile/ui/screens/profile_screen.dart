import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/app_dashed_divider.dart';
import 'package:elfulk/src/core/widgets/settings_list_tile.dart';
import 'package:elfulk/src/core/widgets/user_header_card.dart';
import 'package:elfulk/src/features/parent_features/profile/data/kids_repository.dart';

/// الحساب الشخصي للأب حسب التصميم (عربي RTL، جذر تبويب الحساب).
///
/// ترويسة المستخدم + بطاقة قائمة (صف تبديل + صفوف أطفال + أطفالي +
/// أجهزة) + بطاقة (إعدادات التطبيق/الحساب). تدفقات PIN والحذف هنا.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _kidMode = false;

  static const List<List<Color>> _avatarGradients = <List<Color>>[
    [Color(0xFF55B5A6), Color(0xFF2E8C84)],
    [Color(0xFFEBA5AC), Color(0xFFE93C6E)],
    [Color(0xFFF6C453), Color(0xFFF59E0B)],
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<KidItem> kids = const KidsRepository().fetchKids();

    return SafeArea(
      child: ListView(
        padding: context.spacing.pagePadding,
        children: [
          Center(
            child: Text(
              'الحساب الشخصي',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: context.spacing.md.h),
          UserHeaderCard(
            name: 'اسم المستخدم',
            email: 'example123@gmail.com',
            stats: const [
              StatData(
                label: 'عدد الأطفال',
                value: '3 أطفال',
                valueColor: Color(0xFF2E8C84),
              ),
              StatData(
                label: 'الأجهزة المرتبطة',
                value: '3 أجهزة',
                valueColor: Color(0xFF2E8C84),
              ),
              StatData(
                label: 'التنبيهات المعلقة',
                value: '3 تنبيهات',
                valueColor: Color(0xFFF59E0B),
              ),
            ],
            onMenu: () => _showHeaderMenu(context),
          ),
          SizedBox(height: context.spacing.md.h),
          _GroupCard(
            children: [
              SettingsListTile(
                title: 'الانتقال إلى واجهة الطفل',
                leading: const Icon(Icons.people_outline_rounded),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: SettingsTileTrailing.switch_(
                  value: _kidMode,
                  onChanged: (bool v) => setState(() => _kidMode = v),
                ),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                dashedDivider: true,
              ),
              for (int i = 0; i < kids.length; i++) ...[
                _ProfileChildRow(
                  name: kids[i].name,
                  usage: 'مدة الاستخدام: 2 ساعات و 10 دقائق.',
                  gradient: _avatarGradients[i % _avatarGradients.length],
                  dashedDivider: i < kids.length - 1,
                ),
              ],
              SettingsListTile(
                title: 'أطفالي',
                leading: const Icon(Icons.people_outline_rounded),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: const SettingsTileTrailing.chevron(),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                dashedDivider: true,
                onTap: () => context.push(Routes.parentKidsScreen),
              ),
              SettingsListTile(
                title: 'الأجهزة المرتبطة',
                leading: const Icon(Icons.devices_outlined),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: const SettingsTileTrailing.chevron(),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                onTap: () => context.push(Routes.linkedDevicesScreen),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md.h),
          _GroupCard(
            children: [
              SettingsListTile(
                title: 'إعدادات التطبيق',
                leading: const Icon(Icons.settings_outlined),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: const SettingsTileTrailing.chevron(),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                dashedDivider: true,
                onTap: () => context.push(Routes.appSettingsScreen),
              ),
              SettingsListTile(
                title: 'إعدادات الحساب',
                leading: const Icon(Icons.person_outline_rounded),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: const SettingsTileTrailing.chevron(),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                dashedDivider: true,
                onTap: () => context.push(Routes.accountSettingsScreen),
              ),
              SettingsListTile(
                title: 'المساعدة والدعم',
                leading: const Icon(Icons.help_outline_rounded),
                leadingBackgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                trailing: const SettingsTileTrailing.chevron(),
                backgroundColor: Colors.transparent,
                borderRadius: 0,
                showDivider: false,
                onTap: () => context.push(Routes.helpScreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// قائمة ⋯ في الترويسة: نسخ البريد (حقيقي) أو تعديل البيانات.
  Future<void> _showHeaderMenu(BuildContext context) async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('نسخ البريد الإلكتروني'),
              onTap: () => Navigator.of(sheetContext).pop('copy'),
            ),
            ListTile(
              title: const Text('تعديل البيانات'),
              onTap: () => Navigator.of(sheetContext).pop('edit'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'copy' && context.mounted) {
      await Clipboard.setData(
        const ClipboardData(text: 'example123@gmail.com'),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ البريد الإلكتروني.')),
        );
      }
    } else if (choice == 'edit' && context.mounted) {
      context.push(Routes.editPersonalInfoScreen);
    }
  }
}

/// بطاقة مجموعة: خلفية بيضاء وزاوية مستديرة تحتضن صفوفاً شفافة.
class _GroupCard extends StatelessWidget {
  final List<Widget> children;

  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.xxl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// صف طفل مضغوط في قائمة الحساب (أفاتار + اسم + مدة + شيفرون).
class _ProfileChildRow extends StatelessWidget {
  final String name;
  final String usage;
  final List<Color> gradient;
  final bool dashedDivider;

  const _ProfileChildRow({
    required this.name,
    required this.usage,
    required this.gradient,
    this.dashedDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md.w,
            vertical: context.spacing.sm.h,
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradient,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.characters.first,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.spacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      usage,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.spacing.sm.w),
              Icon(
                Icons.chevron_left_rounded,
                size: 20.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        if (dashedDivider)
          const AppDashedDivider(key: ValueKey('profile-child-divider'))
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
