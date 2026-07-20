import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/domain/use_cases.dart';
import 'package:soriana_character_explorer/features/characters/presentation/pages/location_page.dart';

class _GetLocation extends Mock implements GetLocation {}

void main() {
  testWidgets('presents a loaded location profile with its facts', (
    tester,
  ) async {
    final getLocation = _GetLocation();
    const location = LocationDetail(
      id: 20,
      name: 'Earth (Replacement Dimension)',
      type: 'Planet',
      dimension: 'Replacement Dimension',
      residentCount: 4,
    );
    when(() => getLocation(20)).thenAnswer((_) async => location);

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<GetLocation>.value(
          value: getLocation,
          child: const LocationDetailPage(id: 20),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ARCHIVO DE UBICACIÓN'), findsOneWidget);
    expect(find.text(location.name), findsNWidgets(2));
    expect(find.text('UBICACIÓN #020'), findsOneWidget);
    expect(find.text('TIPO'), findsOneWidget);
    expect(find.text('Planet'), findsNWidgets(2));
    expect(find.text('DIMENSIÓN'), findsOneWidget);
    expect(find.text('Replacement Dimension'), findsOneWidget);
    expect(find.text('RESIDENTES'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('registrados'), findsOneWidget);
    verify(() => getLocation(20)).called(1);
  });
}
