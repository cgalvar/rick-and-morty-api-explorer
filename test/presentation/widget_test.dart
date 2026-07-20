import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soriana_character_explorer/core/presentation/app_icon_set.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/presentation/widgets.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_repository.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_use_cases.dart';
import 'package:soriana_character_explorer/features/favorites/presentation/favorites_cubit.dart';

class Memory implements FavoritesRepository {
  @override
  Future<Set<int>> read() async => {};
  @override
  Future<void> write(Set<int> ids) async {}
}

void main() {
  const c = Character(
    id: 1,
    name: 'Rick',
    status: CharacterStatus.alive,
    species: 'Human',
    gender: 'Male',
    type: '',
    image: '',
    origin: CharacterLocation('Earth'),
    location: CharacterLocation('Earth'),
    episodeCount: 1,
  );
  testWidgets('card gives semantic status and favorite control', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) {
            final favorites = Memory();
            return FavoritesCubit(
              LoadFavorites(favorites),
              SaveFavorites(favorites),
            );
          },
          child: Scaffold(
            body: CharacterCard(character: c, onOpen: () {}),
          ),
        ),
      ),
    );
    expect(find.text('Alive'), findsOneWidget);
    expect(find.byTooltip('Favorito'), findsOneWidget);
    expect(
      find.byIcon(AppIcons.resolve(AppIcon.favoriteUnselected)),
      findsOneWidget,
    );
    await t.tap(find.byTooltip('Favorito'));
    await t.pump();
    expect(
      find.byIcon(AppIcons.resolve(AppIcon.favoriteSelected)),
      findsOneWidget,
    );
  });

  testWidgets('async error view retries on user interaction', (t) async {
    var retried = false;
    await t.pumpWidget(
      MaterialApp(
        home: AsyncStateView(
          message: 'Sin conexión.',
          onRetry: () => retried = true,
        ),
      ),
    );

    await t.tap(find.text('Reintentar'));
    expect(retried, isTrue);
  });
}
