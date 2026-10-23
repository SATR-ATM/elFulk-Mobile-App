import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/features/app_features/home/data/repos/home_dashboard_repository.dart';
import 'package:elfulk/src/features/app_features/home/logic/dashboard_cubit/home_dashboard_cubit.dart';
import 'package:elfulk/src/features/app_features/home/ui/screens/home_screen.dart';
import 'package:elfulk/src/features/app_features/notifications/data/repos/notifications_repository.dart';
import 'package:elfulk/src/features/app_features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:elfulk/src/features/parent_features/add_child/ui/screens/Add_new_child_screen.dart';
import 'package:elfulk/src/features/parent_features/content/ui/screens/details_screen.dart';
import 'package:elfulk/src/features/parent_features/control_center/ui/screens/control_home_screen.dart';
import 'package:elfulk/src/features/parent_features/profile/ui/screens/profile_screen.dart';

Widget _app(GoRouter router) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, child) => MaterialApp.router(routerConfig: router),
  );
}

Widget _home() {
  return Scaffold(
    body: MultiBlocProvider(
      providers: [
        BlocProvider<HomeDashboardCubit>(
          create: (_) =>
              HomeDashboardCubit(const HomeDashboardRepository())..load(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) =>
              NotificationsCubit(const NotificationsRepository())..load(),
        ),
      ],
      child: const HomeScreen(),
    ),
  );
}

Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _dismissUpsell(WidgetTester tester) async {
  await tester.pumpAndSettle();
  if (find
      .byKey(const ValueKey('app-confirmation-secondary'))
      .evaluate()
      .isNotEmpty) {
    await tester.tap(find.byKey(const ValueKey('app-confirmation-secondary')));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('home library row and section action open the content hub', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => _home()),
        GoRoute(
          path: '/content',
          builder: (context, state) => const Text('content-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await _dismissUpsell(tester);

    final Finder row = find.byKey(const ValueKey('library-content-row')).first;
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('content-stub'), findsOneWidget);
  });

  testWidgets('home section action opens the content hub', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => _home()),
        GoRoute(
          path: '/content',
          builder: (context, state) => const Text('content-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await _dismissUpsell(tester);

    final Finder action = find
        .byKey(const ValueKey('library-section-action'))
        .first;
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('content-stub'), findsOneWidget);
  });

  testWidgets('child card action opens the child app placeholder', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => _home()),
        GoRoute(
          path: '/child',
          builder: (context, state) => const Text('child-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await _dismissUpsell(tester);

    final Finder action = find.text('الانتقال إلى وجهته الخاصة').first;
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('child-stub'), findsOneWidget);
  });

  testWidgets('profile opens help and support', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ProfileScreen()),
        GoRoute(
          path: '/profile/help',
          builder: (context, state) => const Text('help-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    final Finder tile = find.text('المساعدة والدعم');
    await _scrollTo(tester, tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('help-stub'), findsOneWidget);
  });

  testWidgets('control center opens the rules hub', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: ControlHomeScreen()),
        ),
        GoRoute(
          path: '/control/rules',
          builder: (context, state) => const Text('rules-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    final Finder tile = find.byKey(const ValueKey('control-rules-entry'));
    await _scrollTo(tester, tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('rules-stub'), findsOneWidget);
  });

  testWidgets('story details opens the reader', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: DetailsScreen(itemId: 's1')),
        ),
        GoRoute(
          path: '/content/reader',
          builder: (context, state) => const Text('reader-stub'),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    final Finder cta = find.byKey(const ValueKey('details-consume'));
    await _scrollTo(tester, cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('reader-stub'), findsOneWidget);
  });

  testWidgets('add child deletes its row', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AddNewChildScreen(),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('add-child-info-row')), findsOneWidget);

    await _scrollTo(tester, find.byKey(const ValueKey('add-child-delete-row')));
    await tester.tap(find.byKey(const ValueKey('add-child-delete-row')));
    await tester.pump();
    expect(find.byKey(const ValueKey('add-child-info-row')), findsNothing);
    expect(find.text('تم حذف بيانات الطفل.'), findsOneWidget);
  });

  testWidgets('add child resets the form for another child', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AddNewChildScreen(),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const ValueKey('add-child-another')));
    await tester.tap(find.byKey(const ValueKey('add-child-another')));
    await tester.pump();
    expect(find.text('أدخل بيانات الطفل الجديد.'), findsOneWidget);
  });

  testWidgets('add child requires a name before submitting', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AddNewChildScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const AddNewChildScreen(),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('الانتقال إلى لوحة التحكم'));
    await tester.tap(find.text('الانتقال إلى لوحة التحكم'));
    await tester.pump();
    expect(find.text('أدخل اسم طفلك.'), findsOneWidget);
  });
}
