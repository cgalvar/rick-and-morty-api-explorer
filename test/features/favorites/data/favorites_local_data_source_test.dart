import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soriana_character_explorer/features/favorites/data/favorites_local_data_source.dart';

class _Preferences extends Mock implements SharedPreferences {}

void main() {
  late _Preferences preferences;
  late FavoritesLocalDataSource source;

  setUp(() {
    preferences = _Preferences();
    source = FavoritesLocalDataSource(preferences);
  });

  test('fails a write when SharedPreferences returns false', () async {
    when(
      () => preferences.setStringList('favorite_character_ids', ['1']),
    ).thenAnswer((_) async => false);

    await expectLater(source.write({1}), throwsA(isA<StateError>()));
  });

  test('ignores corrupt persisted IDs while retaining valid values', () async {
    when(
      () => preferences.getStringList('favorite_character_ids'),
    ).thenReturn(['1', 'bad', '2', '']);

    expect(await source.read(), {1, 2});
  });
}
