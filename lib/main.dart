import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/characters/domain/use_cases.dart';
import 'features/favorites/domain/favorites_use_cases.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final getIt = GetIt.instance;
  await configureDependencies(getIt);
  runApp(
    App(
      router: AppRouter(),
      getCharacters: getIt<GetCharacters>(),
      getCharacter: getIt<GetCharacter>(),
      getLocation: getIt<GetLocation>(),
      loadFavorites: getIt<LoadFavorites>(),
      saveFavorites: getIt<SaveFavorites>(),
    ),
  );
}
