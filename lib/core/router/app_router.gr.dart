// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CharacterDetailPage]
class CharacterDetailRoute extends PageRouteInfo<CharacterDetailRouteArgs> {
  CharacterDetailRoute({
    Key? key,
    required int id,
    Character? initialCharacter,
    List<PageRouteInfo>? children,
  }) : super(
         CharacterDetailRoute.name,
         args: CharacterDetailRouteArgs(
           key: key,
           id: id,
           initialCharacter: initialCharacter,
         ),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'CharacterDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CharacterDetailRouteArgs>(
        orElse: () => CharacterDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return CharacterDetailPage(
        key: args.key,
        id: args.id,
        initialCharacter: args.initialCharacter,
      );
    },
  );
}

class CharacterDetailRouteArgs {
  const CharacterDetailRouteArgs({
    this.key,
    required this.id,
    this.initialCharacter,
  });

  final Key? key;

  final int id;

  final Character? initialCharacter;

  @override
  String toString() {
    return 'CharacterDetailRouteArgs{key: $key, id: $id, initialCharacter: $initialCharacter}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CharacterDetailRouteArgs) return false;
    return key == other.key &&
        id == other.id &&
        initialCharacter == other.initialCharacter;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode ^ initialCharacter.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LocationDetailPage]
class LocationDetailRoute extends PageRouteInfo<LocationDetailRouteArgs> {
  LocationDetailRoute({
    Key? key,
    required int id,
    List<PageRouteInfo>? children,
  }) : super(
         LocationDetailRoute.name,
         args: LocationDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'LocationDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LocationDetailRouteArgs>(
        orElse: () => LocationDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return LocationDetailPage(key: args.key, id: args.id);
    },
  );
}

class LocationDetailRouteArgs {
  const LocationDetailRouteArgs({this.key, required this.id});

  final Key? key;

  final int id;

  @override
  String toString() {
    return 'LocationDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocationDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}
