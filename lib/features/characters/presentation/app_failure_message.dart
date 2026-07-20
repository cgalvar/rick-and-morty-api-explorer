import '../../../core/error/app_failure.dart';

extension AppFailureMessage on AppFailure {
  String get message => switch (kind) {
    AppFailureKind.charactersNotFound => 'No se encontraron personajes.',
    AppFailureKind.locationNotFound => 'No se encontró la ubicación.',
    AppFailureKind.timeout => 'La solicitud tardó demasiado. Intenta de nuevo.',
    AppFailureKind.offline => 'Sin conexión. Revisa tu red.',
    AppFailureKind.serverUnavailable => 'El servidor no está disponible.',
    AppFailureKind.invalidResponse ||
    AppFailureKind.unexpected => 'Ocurrió un error inesperado.',
  };
}
