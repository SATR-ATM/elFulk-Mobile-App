import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/di/dependency_injection.dart';
import 'package:elfulk/src/features/app_features/auth/ui/screens/login_screen.dart';
import 'package:elfulk/src/features/app_features/auth/ui/screens/register_screen.dart';
import 'package:elfulk/src/features/app_features/auth/ui/screens/forget_password_screen.dart';
import 'package:elfulk/src/features/app_features/architecture/logic/cubit/architecture_cubit.dart';
import 'package:elfulk/src/features/app_features/architecture/ui/screens/architecture_overview_screen.dart';
import 'package:elfulk/src/features/app_features/home/logic/cubit/home_cubit.dart';
import 'package:elfulk/src/features/app_features/home/ui/screens/home_screen.dart';
import 'package:elfulk/src/features/child_features/child_home/logic/cubit/child_home_cubit.dart';
import 'package:elfulk/src/features/child_features/child_home/ui/screens/child_home_screen.dart';
import 'package:elfulk/src/features/parent_features/parent_home/logic/cubit/parent_home_cubit.dart';
import 'package:elfulk/src/features/parent_features/parent_home/ui/screens/parent_home_screen.dart';
import 'package:elfulk/src/features/parent_features/parent_requests/logic/bloc/parent_requests_bloc.dart';
import 'package:elfulk/src/features/parent_features/parent_requests/ui/screens/parent_requests_screen.dart';

import '../../../features/app_features/auth/ui/screens/otp_verification_screen.dart';
import 'routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: Routes.homeScreen,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.homeScreen,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
              child: BlocProvider<HomeCubit>(
                create: (_) => getIt<HomeCubit>()..loadOverview(),
                child: const HomeScreen(),
              ),
            ),
      ),
      GoRoute(
        path: Routes.loginScreen,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                const MaterialPage<void>(child: LoginScreen()),
      ),
      GoRoute(
        path: Routes.registerScreen,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                const MaterialPage<void>(child: RegisterScreen()),

      ),
      GoRoute(path: Routes.otpVerificationScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final OtpVerificationType type = state.uri.queryParameters['type'] == 'email'
              ? OtpVerificationType.emailVerification
              : OtpVerificationType.passwordReset;
          return MaterialPage<void>(
            child: OtpVerificationScreen(type: type),
          );
        },
      ),
      GoRoute(
        path: Routes.forgetPasswordScreen,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                const MaterialPage<void>(child: ForgetPasswordScreen()),
      ),
      GoRoute(
        path: Routes.parentHomeScreen,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
              child: BlocProvider<ParentHomeCubit>(
                create: (_) => getIt<ParentHomeCubit>()..loadOverview(),
                child: const ParentHomeScreen(),
              ),
            ),
      ),
      GoRoute(
        path: Routes.parentRequestsScreen,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
              child: BlocProvider<ParentRequestsBloc>(
                create: (_) =>
                    getIt<ParentRequestsBloc>()
                      ..add(const ParentRequestsEvent.loadData()),
                child: const ParentRequestsScreen(),
              ),
            ),
      ),
      GoRoute(
        path: Routes.childHomeScreen,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
              child: BlocProvider<ChildHomeCubit>(
                create: (_) => getIt<ChildHomeCubit>()..loadOverview(),
                child: const ChildHomeScreen(),
              ),
            ),
      ),
      GoRoute(
        path: Routes.architectureScreen,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            MaterialPage<void>(
              child: BlocProvider<ArchitectureCubit>(
                create: (_) => getIt<ArchitectureCubit>()..loadOverview(),
                child: const ArchitectureOverviewScreen(),
              ),
            ),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unknown route')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(
              'No screen is registered for ${state.uri.toString()}.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    },
  );
}
