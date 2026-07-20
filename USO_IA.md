# Uso de IA

Se utilizó asistencia de IA como apoyo para estructurar el proyecto, redactar documentación y acelerar implementación/revisión. El resultado fue revisado con análisis y pruebas locales.

Prompts representados por este trabajo:

- “Crea un explorador Flutter de personajes Rick and Morty con Clean Architecture, BLoC, Chopper e inyección.”
- “Implementa estados de carga, vacío, error, búsqueda con debounce, filtros y paginación segura.”
- “Documenta decisiones, accesibilidad, pruebas y CI de una prueba técnica.”

## Revisión humana y correcciones

- Se corrigió una condición de carrera en paginación: una recarga podía invalidar
  una solicitud de página siguiente y dejar `loadingMore` activo. Se pidió a la
  IA limpiar ese estado al reemplazar la lista y añadir una prueba de regresión
  que confirma que la siguiente página vuelve a poder cargarse.
- Se rechazó una simplificación de favoritos que hacía que `FavoritesCubit`
  dependiera directamente del repositorio. Se restauraron `LoadFavorites` y
  `SaveFavorites`, su inyección y las pruebas para preservar la separación de
  la capa de dominio.
- Se rechazó obtener todos los personajes al iniciar. La aplicación consulta
  solamente la página y filtros solicitados para conservar paginación
  incremental y evitar consumo innecesario.
