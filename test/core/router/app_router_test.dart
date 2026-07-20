import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soriana_character_explorer/core/router/app_router.dart';
import 'package:soriana_character_explorer/features/characters/presentation/pages/detail_page.dart';
import 'package:soriana_character_explorer/features/characters/presentation/pages/location_page.dart';

void main() {
  final router = AppRouter();

  test('matches a deep-link detail path with its typed ID', () {
    final matches = router.matcher.match('/characters/1');
    final match = matches!.single;

    expect(match.name, CharacterDetailRoute.name);
    expect(match.params.getInt('id'), 1);

    final page = CharacterDetailRoute.page.builder(
      RouteData<void>(
        route: match,
        router: router,
        stackKey: const ValueKey('router-test'),
        pendingChildren: const [],
        type: const RouteType.material(),
      ),
    );

    expect(page, isA<CharacterDetailPage>());
    expect((page as CharacterDetailPage).id, 1);
    expect(page.initialCharacter, isNull);
  });

  test('matches a deep-link location path with its typed ID', () {
    final matches = router.matcher.match('/locations/20');
    final match = matches!.single;

    expect(match.name, LocationDetailRoute.name);
    expect(match.params.getInt('id'), 20);

    final page = LocationDetailRoute.page.builder(
      RouteData<void>(
        route: match,
        router: router,
        stackKey: const ValueKey('location-router-test'),
        pendingChildren: const [],
        type: const RouteType.material(),
      ),
    );

    expect(page, isA<LocationDetailPage>());
    expect((page as LocationDetailPage).id, 20);
  });

  test('redirects an unmatched path to home', () {
    final matches = router.matcher.match('/not-a-route');
    final match = matches!.single;

    expect(match.name, HomeRoute.name);
    expect(match.fromRedirect, isTrue);
    expect(match.redirectedFrom, '*');
  });
}
