import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soriana_character_explorer/features/characters/domain/character_repository.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/domain/use_cases.dart';
import 'package:soriana_character_explorer/features/characters/presentation/pages/detail_page.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_repository.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_use_cases.dart';
import 'package:soriana_character_explorer/features/favorites/presentation/favorites_cubit.dart';

class _PendingCharacterRepository implements CharacterRepository {
  final pending = Completer<Character>();

  @override
  Future<Character> getCharacter(int id) => pending.future;

  @override
  Future<CharacterPage> getCharacters({
    int page = 1,
    String name = '',
    CharacterStatus? status,
  }) => throw UnimplementedError();
}

class _MemoryFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<int>> read() async => {};

  @override
  Future<void> write(Set<int> ids) async {}
}

void main() {
  const character = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    gender: 'Male',
    type: '',
    image: '',
    origin: CharacterLocation('Earth'),
    location: CharacterLocation('Citadel'),
    episodeCount: 51,
  );

  testWidgets('keeps the destination Hero mounted while detail refreshes', (
    tester,
  ) async {
    final repository = _PendingCharacterRepository();
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GetCharacter>(
            create: (_) => GetCharacter(repository),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) {
              final favorites = _MemoryFavoritesRepository();
              return FavoritesCubit(
                LoadFavorites(favorites),
                SaveFavorites(favorites),
              );
            },
            child: CharacterDetailPage(
              id: character.id,
              initialCharacter: character,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'character-${character.id}',
      ),
      findsOneWidget,
    );
    expect(find.text(character.name), findsWidgets);

    repository.pending.complete(character);
    await tester.pump();
  });
}
