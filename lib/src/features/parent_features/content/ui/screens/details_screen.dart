import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/routing/routes.dart';

import 'package:elfulk/src/core/helpers/helpers.dart';
import 'package:elfulk/src/core/widgets/app_error_card.dart';
import 'package:elfulk/src/core/widgets/category_chip.dart';
import 'package:elfulk/src/core/widgets/details_hero.dart';
import 'package:elfulk/src/features/parent_features/content/data/content_seed.dart';

/// صفحة تفاصيل عنصر محتوى حسب التصميم (عربي RTL).
///
/// ترويسة بطولية + غلاف متداخل + عنوان + شارات + بطاقة وصف +
/// بطاقة بيانات + زر CTA سفلي ثابت. المحتوى من البذر المحلي برقم
/// المعرف (`id`) — صفحة خطأ لطيفة للمعرف الغائب.
class DetailsScreen extends StatelessWidget {
  final String itemId;

  const DetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ContentItem? item = ContentSeed.byId(itemId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التفاصيل'),
        centerTitle: true,
        actions: const [Icon(Icons.more_vert_rounded)],
      ),
      body: SafeArea(
        child: item == null
            ? Padding(
                padding: context.spacing.pagePadding,
                child: const AppErrorCard(message: 'العنصر المطلوب غير موجود.'),
              )
            : _DetailsBody(item: item, theme: theme),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final ContentItem item;
  final ThemeData theme;

  const _DetailsBody({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.spacing.pagePadding,
      children: [
        DetailsHero(
          backdrop: Container(color: item.artColor.withValues(alpha: 0.3)),
          cover: Container(
            color: item.artColor.withValues(alpha: 0.5),
            child: Center(
              child: Icon(
                Icons.videogame_asset_outlined,
                size: 56.sp,
                color: Colors.white,
              ),
            ),
          ),
          title: item.title,
          badges: [
            for (int i = 0; i < item.tags.length; i++)
              ContentBadge(
                label: item.tags[i],
                background: const [
                  Color(0xFFFDD6D6),
                  Color(0xFFFEEDC9),
                  Color(0xFFD1E9E7),
                ][i % 3],
                foreground: const [
                  Color(0xFFD32F2F),
                  Color(0xFFF59E0B),
                  Color(0xFF2E8C84),
                ][i % 3],
              ),
          ],
        ),
        SizedBox(height: context.spacing.md.h),
        Material(
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.radius.xl.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(context.spacing.md.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'وصف للقصة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.spacing.md.h),
        _MetadataCard(item: item),
        SizedBox(height: context.spacing.lg.h),
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            key: const ValueKey('details-download'),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('بدأ التحميل.')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius.xl.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'تحميل',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: context.spacing.sm.w),
                const Icon(Icons.download_outlined, size: 20),
              ],
            ),
          ),
        ),
        SizedBox(height: context.spacing.sm.h),
        SizedBox(
          height: 48.h,
          child: OutlinedButton(
            key: const ValueKey('details-consume'),
            onPressed: item.type == ContentType.stories
                ? () => context.push(
                    Uri(
                      path: Routes.readerScreen,
                      queryParameters: <String, String>{'id': item.id},
                    ).toString(),
                  )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item.type == ContentType.games
                            ? 'تُفتح اللعبة من جهاز طفلك بعد إقران الجهاز.'
                            : 'تُتاح المشاهدة من جهاز طفلك بعد إقران الجهاز.',
                      ),
                    ),
                  ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.45),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius.xl.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    item.type == ContentType.stories
                        ? 'قراءة الآن'
                        : item.type == ContentType.games
                        ? 'الدخول إلى اللعبة'
                        : 'مشاهدة',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: context.spacing.sm.w),
                Icon(
                  item.type == ContentType.stories
                      ? Icons.menu_book_outlined
                      : item.type == ContentType.games
                      ? Icons.sports_esports_outlined
                      : Icons.play_circle_outline_rounded,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// بطاقة البيانات الوصفية (3 صفوف بفواصل: تسمية يميناً وقيمة يساراً).
class _MetadataCard extends StatelessWidget {
  final ContentItem item;

  const _MetadataCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget row(String label, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.sm.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(width: context.spacing.sm.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.xl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing.md.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row('النوع', item.badge),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: theme.colorScheme.outlineVariant,
            ),
            row('المدة', 'متوسطة'),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: theme.colorScheme.outlineVariant,
            ),
            row('الحالة', 'متاح'),
          ],
        ),
      ),
    );
  }
}
