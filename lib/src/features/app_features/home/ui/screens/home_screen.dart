import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:elfulk/src/core/config/app_environment.dart';
import 'package:elfulk/src/core/config/di/dependency_injection.dart';
import 'package:elfulk/src/core/config/routing/routes.dart';
import 'package:elfulk/src/core/networking/helper/api_constants.dart';
import 'package:elfulk/src/core/widgets/app_section_card.dart';
import 'package:elfulk/src/features/app_features/home/data/view_models/home_overview_view_model.dart';
import 'package:elfulk/src/features/app_features/home/logic/cubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        return state.when(
          initial: () => const _HomeLoadingView(),
          loading: () => const _HomeLoadingView(),
          loaded: (HomeOverviewViewModel overview) =>
              _HomeLoadedView(overview: overview),
          error: (error) => _HomeErrorView(message: error.detail),
        );
      },
    );
  }
}

class _HomeLoadedView extends StatelessWidget {
  const _HomeLoadedView({required this.overview});

  final HomeOverviewViewModel overview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppEnvironment environment = getIt<AppEnvironment>();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF8F4EC), Color(0xFFF0E7D8)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(20.r),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF10363A),
                      Color(0xFF0F766E),
                      Color(0xFF4D9C90),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0x300F766E),
                      blurRadius: 32.r,
                      offset: Offset(0, 18.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        'Flavor: ${environment.apiEnvironmentLabel}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'ElFulk App Features',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      overview.headline,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFE8FBF8),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      overview.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFE2F5F1),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: <Widget>[
                        FilledButton.tonal(
                          onPressed: () =>
                              context.push(Routes.parentHomeScreen),
                          style: _buttonStyle(),
                          child: const Text('Open parent example'),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              context.push(Routes.loginScreen),
                          style: _buttonStyle(),
                          child: const Text('Open Auth (Login)'),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              context.push(Routes.parentRequestsScreen),
                          style: _buttonStyle(),
                          child: const Text('Open parent Bloc example'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => context.push(Routes.childHomeScreen),
                          style: _buttonStyle(),
                          child: const Text('Open child example'),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              context.push(Routes.architectureScreen),
                          style: _buttonStyle(),
                          child: const Text('Open architecture'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              AppSectionCard(
                eyebrow: 'Networking',
                title: 'Dummy networking wired through the app stack',
                accentColor: const Color(0xFF1D4ED8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: <Widget>[
                        _InfoChip(
                          label: 'Resolved base URL',
                          value: apiBaseUrl,
                        ),
                        _InfoChip(
                          label: 'Mocked endpoint',
                          value: overview.endpoint,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Flow: HomeCubit -> HomeRepository -> AppApiService -> DioFactory -> DummyApiInterceptor',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              AppSectionCard(
                eyebrow: 'Principles',
                title: 'Current implementation principles',
                accentColor: colorScheme.primary,
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: overview.principles
                      .map(
                        (String principle) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7F5),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            principle,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF0F5A56),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 20.h),
              AppSectionCard(
                eyebrow: 'Feature Groups',
                title: 'Scaffolded modules in this repo',
                accentColor: const Color(0xFF0F766E),
                child: Column(
                  children: overview.modules
                      .map(
                        (FeatureModuleViewModel module) =>
                            _ModuleTile(module: module),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 20.h),
              AppSectionCard(
                eyebrow: 'Next',
                title: 'Recommended evolution path',
                accentColor: const Color(0xFFB7791F),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: overview.nextMilestones
                      .map(
                        (String step) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 8.w,
                                height: 8.w,
                                margin: EdgeInsets.only(top: 7.h),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB7791F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  step,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final FeatureModuleViewModel module;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE0D7C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  module.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  module.status,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF246B3D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(module.description, style: theme.textTheme.bodyLarge),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: module.folders
                .map(
                  (String folder) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F5),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      folder,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 14.h),
          Text(
            module.nextStep,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B554A),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ElFulk')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F5),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text('$label: $value'),
    );
  }
}
