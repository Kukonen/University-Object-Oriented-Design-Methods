// ignore_for_file: prefer-match-file-name

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:surf_mad_teacher_training/feature/bottom_nav/presentation/bottom_nav_screen.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/favorites/presentation/favorites_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/filter/presentation/filter_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/presentation/onboarding_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/places/presentation/places_list/places_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/search/presentation/search_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/settings/presentation/settings_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/splash/presentation/splash_screen_builder.dart';
import 'package:surf_mad_teacher_training/navigation/route_paths.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRouteBuilder.page, path: RoutePaths.splash, initial: true),
    CustomRoute(
      page: OnboardingRouteBuilder.page,
      path: RoutePaths.onboarding,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    AutoRoute(
      page: BottomNavRoute.page,
      path: RoutePaths.main,
      children: [
        AutoRoute(
          page: PlacesTabRoute.page,
          path: RoutePaths.places,
          initial: true,
          children: [
            AutoRoute(page: PlacesRouteBuilder.page, path: '', initial: true),
            CustomRoute(
              page: SearchRouteBuilder.page,
              path: 'search',
              transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
            ),
            CustomRoute(
              page: FilterRouteBuilder.page,
              path: 'filter',
              transitionsBuilder: TransitionsBuilders.slideBottom,
            ),
            _details(),
          ],
        ),
        AutoRoute(
          page: FavoritesTabRoute.page,
          path: RoutePaths.favorites,
          children: [
            AutoRoute(page: FavoritesRouteBuilder.page, path: '', initial: true),
            _details(),
          ],
        ),
        AutoRoute(
          page: SettingsTabRoute.page,
          path: RoutePaths.settings,
          children: [
            AutoRoute(page: SettingsRouteBuilder.page, path: '', initial: true),
          ],
        ),
      ],
    ),
  ];

  CustomRoute<dynamic> _details() => CustomRoute(
    page: PlaceDetailRouteBuilder.page,
    path: 'details',
    transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
  );
}

@RoutePage(name: 'PlacesTabRoute')
class PlacesTabPage extends AutoRouter {
  const PlacesTabPage({super.key});
}

@RoutePage(name: 'FavoritesTabRoute')
class FavoritesTabPage extends AutoRouter {
  const FavoritesTabPage({super.key});
}

@RoutePage(name: 'SettingsTabRoute')
class SettingsTabPage extends AutoRouter {
  const SettingsTabPage({super.key});
}
