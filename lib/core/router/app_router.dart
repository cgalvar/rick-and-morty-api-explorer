import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/characters/domain/entities.dart';
import '../../features/characters/presentation/pages/detail_page.dart';
import '../../features/characters/presentation/pages/home_page.dart';
import '../../features/characters/presentation/pages/location_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/', initial: true),
    CustomRoute<void>(
      page: CharacterDetailRoute.page,
      path: '/characters/:id',
      duration: const Duration(milliseconds: 380),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          MediaQuery.disableAnimationsOf(context)
          ? child
          : FadeTransition(opacity: animation, child: child),
    ),
    AutoRoute(page: LocationDetailRoute.page, path: '/locations/:id'),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
