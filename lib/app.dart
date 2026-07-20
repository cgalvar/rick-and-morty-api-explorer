import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/presentation/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/characters/domain/use_cases.dart';
import 'features/characters/presentation/characters_bloc.dart';
import 'features/favorites/presentation/favorites_cubit.dart';
import 'features/favorites/domain/favorites_use_cases.dart';
import 'features/theme/presentation/theme_cubit.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.router,
    required this.getCharacters,
    required this.getCharacter,
    required this.getLocation,
    required this.loadFavorites,
    required this.saveFavorites,
  });

  final AppRouter router;
  final GetCharacters getCharacters;
  final GetCharacter getCharacter;
  final GetLocation getLocation;
  final LoadFavorites loadFavorites;
  final SaveFavorites saveFavorites;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ThemeCubit()),
      BlocProvider(
        create: (_) =>
            CharactersBloc(getCharacters)..add(const CharactersStarted()),
      ),
      BlocProvider(
        create: (_) => FavoritesCubit(loadFavorites, saveFavorites)..load(),
      ),
    ],
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GetCharacter>.value(value: getCharacter),
        RepositoryProvider<GetLocation>.value(value: getLocation),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          routerConfig: router.config(),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
        ),
      ),
    ),
  );
}
