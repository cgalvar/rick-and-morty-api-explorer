# Reglas de negocio: explorador de personajes

No existía comportamiento previo ni migración: estas son reglas iniciales.

- Buscar espera 400 ms y cancela por completo la espera anterior. Cambiar texto o estado reinicia la paginación e invalida respuestas anteriores.
- La lista 404 significa “Sin resultados”; el detalle 404 es un error recuperable mostrado al usuario.
- Sólo se solicita la página siguiente cuando la API expone `info.next`; solicitudes duplicadas se bloquean durante carga. Si una página posterior falla, se mantienen los personajes ya cargados, se muestra el error recuperable y la persona usuaria debe seleccionar `Reintentar` para solicitar esa misma página; no se reintenta automáticamente.
- Actualizar y reintentar conservan los filtros activos.
- Se persiste exclusivamente el conjunto de IDs favoritos por dispositivo. Si falla la escritura, no se confirma el cambio, se muestra un SnackBar y no afecta navegación.
- La lista está disponible en `/` y el detalle comparte una URL profunda en `/characters/:id`. La navegación interna puede entregar el personaje ya conocido para montar de inmediato su transición visual; la fuente de verdad sigue siendo la carga por ID. Abrir o recargar una URL de detalle no entrega datos iniciales y carga el personaje por su ID serializable; una ruta inválida vuelve a `/`. Este ajuste no cambia políticas, roles ni el modelo de datos.
- El detalle puede enlazar a `/locations/:id`: muestra controles para el origen y la ubicación actual sólo si la URL correspondiente de la API contiene un ID numérico de `location`. Una URL vacía o malformada no muestra un control no funcional. La ubicación muestra nombre, tipo, dimensión y número de residentes; sus errores de red, tiempo de espera o 404 son recuperables mediante `Reintentar`, que conserva el mismo ID.
- La lista usa una columna y margen de 16 px bajo 600 px, dos columnas y 24 px entre 600 y 1023 px, y tres columnas con margen de 32 px y contenido máximo de 1280 px desde 1024 px. El detalle es compacto bajo 600 px y muestra imagen y datos en dos columnas desde 600 px.

Aplica a todos los usuarios y plataformas. No existen roles, tenants, APIs propias, tablas, migraciones ni restablecimiento de datos; las ubicaciones no se persisten ni requieren compatibilidad o migración adicional.
