# Rick & Morty Character Explorer

Aplicación Flutter de evaluación técnica para explorar personajes de la API pública Rick and Morty.

## Arquitectura

El código está separado en `core/` y `features/characters`, `features/favorites` y `features/theme`; los módulos de personajes y favoritos usan `data`, `domain` y `presentation`. Las entidades, contratos y casos de uso no dependen de Flutter, Chopper ni persistencia. La implementación usa repositorios, un servicio REST Chopper generado, `SharedPreferences`, BLoC/Cubit e inyección generada con `get_it`/`injectable`. `main.dart` es sólo la raíz de composición; las páginas y rutas viven en la capa de presentación.

SOLID se aplica separando la API, el mapeo, persistencia, estado y widgets. Se evitó una capa adicional de abstracciones sin una segunda implementación.

## Ejecutar

La versión de Flutter requerida es **3.41.4** (gestionada con FVM).

```bash
fvm flutter pub get
fvm dart run build_runner build
fvm flutter run
fvm flutter analyze
fvm flutter test --coverage
```

### Proxy Proxyman de desarrollo (opcional)

Por defecto la aplicación consulta directamente `https://rickandmortyapi.com/api`.
Para enviar el tráfico nativo HTTP/HTTPS mediante el forward proxy de Proxyman,
compila y ejecútala con:

```bash
fvm flutter run \
  --dart-define=USE_PROXY=true \
  --dart-define=PROXY_HOST=proxy.example.test \
  --dart-define=PROXY_PORT=9099
```

Los valores del proxy se suministran por Dart defines; en VS Code selecciona el
perfil `Flutter: Proxyman`, que incluye los mismos valores. En plataformas con
`dart:io`, la app conserva como destino `https://rickandmortyapi.com/api` y el
transporte usa la directiva de forward proxy, incluido el flujo HTTPS CONNECT.
Para inspeccionar HTTPS, instala y confía el certificado CA de Proxyman en el
dispositivo o simulador; la app no desactiva la validación TLS.

Flutter web no puede configurar un forward proxy desde Dart. Configúralo en el
navegador o sistema operativo; usar `USE_PROXY=true` en web falla al inicializar
el cliente para evitar una conexión directa silenciosa.

## Web y Firebase Hosting

La aplicación web usa rutas con URL: `/` muestra el explorador y
`/characters/:id` abre el detalle del personaje. Firebase Hosting reescribe las
rutas de la SPA a `index.html`, por lo que los enlaces directos y las recargas
conservan la ruta solicitada.

```bash
fvm flutter build web --release --base-href /
npx -y firebase-tools@latest emulators:start --only hosting
npx -y firebase-tools@latest hosting:channel:deploy initial-review --expires 7d
npx -y firebase-tools@latest hosting:clone \
  soriana-char-exp-20260719:initial-review \
  soriana-char-exp-20260719:live
```

- Producción: <https://soriana-char-exp-20260719.web.app>

## Decisiones y límites

La búsqueda se solicita al servidor con debounce y paginación incremental; nunca descarga el catálogo completo. Los favoritos almacenan únicamente IDs. No hay sincronización remota, pantalla de favoritos ni caché de personajes. Los errores de red se muestran en español y las pruebas no hacen llamadas de red.

Las pruebas deterministas cubren el mapeo y los errores de la fuente Chopper simulada, el repositorio, el `CharactersBloc` (debounce, filtros, paginación, actualizar y reintentar), `FavoritesCubit` y las interacciones/semántica de widgets. La CI fija Flutter 3.41.4 y confirma que toda salida generada está actualizada.

## Extras completados

- Favoritos persistentes por dispositivo.
- Animación `Hero` al abrir el perfil.
- Actualización mediante pull-to-refresh.
- Desde el perfil, navegación a la ubicación de origen y ubicación actual cuando la API entrega una URL válida. Las rutas profundas usan `/locations/:id`.

Mejoras futuras: pruebas de integración contra un entorno controlado y telemetría de errores.
