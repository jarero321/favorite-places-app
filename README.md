# favorite_places

Captura lugares favoritos: foto desde la cámara, coordenadas GPS, mapa OpenStreetMap, compartir y persistencia local en SQLite.

Los datos viven solo en el dispositivo. No hay backend.

## Stack

| Capa | Decisión |
|---|---|
| SDK | Dart `^3.11.1`, Flutter Material 3 |
| Estado | `ChangeNotifier` tipado + `InheritedNotifier` para inyección |
| Persistencia | `sqflite` (tabla única `places`) |
| Navegación | `go_router` v17, rutas declaradas en `lib/app/router.dart` |
| Mapa | `flutter_map` + tiles de OpenStreetMap, `latlong2` |
| Servicios | `image_picker`, `geolocator`, `share_plus` envueltos en clases propias |

Sin gestor de estado externo (Provider, Riverpod, Bloc). Sin generación de código. Sin DI container.

## Cómo correrlo

```bash
flutter pub get
flutter run
```

Permisos requeridos: cámara y ubicación. Android e iOS los piden en runtime al usar el flujo de "Add place".

## Arquitectura

Dos carpetas en `lib/`:

- `app/` — código de features. Una carpeta por feature.
- `framework/` — servicios, persistencia, widgets y design tokens transversales. Nada aquí depende de un feature.

```
lib/
├── main.dart                    # bootstrap: instancia repos, VMs y servicios
├── app/
│   ├── router.dart              # GoRouter con todas las rutas
│   └── places/
│       ├── model/place.dart     # modelo tipado + toMap/fromMap
│       ├── places_repository.dart  # CRUD contra sqflite
│       ├── places_scope.dart    # InheritedNotifier que expone el VM
│       ├── viewmodel/
│       │   └── places_view_model.dart   # ChangeNotifier
│       └── view/
│           ├── places_list_view.dart
│           ├── add_place_view.dart
│           └── place_detail_view.dart
└── framework/
    ├── camera/, location/, share/   # servicios envueltos
    ├── db/app_database.dart         # singleton sqflite
    ├── design/                      # tokens (colors, spacing, radii, durations, theme)
    └── widgets/                     # widgets reutilizados por ≥2 features
```

### El patrón: Repository → ViewModel → Scope → View

Las cuatro piezas se ven en el feature `places`:

1. **Repository** (`places_repository.dart`) — única superficie hacia la base de datos. Recibe `AppDatabase` por constructor. Devuelve modelos tipados, nunca `Map<String, dynamic>`.

2. **ViewModel** (`viewmodel/places_view_model.dart`) — extiende `ChangeNotifier`. Mantiene `places`, `loading`, `error`. Métodos públicos (`load`, `addPlace`, `delete`) actualizan estado y llaman `notifyListeners()`. No conoce a `BuildContext` ni widgets.

3. **Scope** (`places_scope.dart`) — `InheritedNotifier<PlacesViewModel>`. Expone dos accesores:
   - `PlacesScope.of(context)` — suscribe el widget a rebuilds.
   - `PlacesScope.read(context)` — lectura sin suscripción, para callbacks (`onPressed`).

4. **View** (`view/*.dart`) — obtiene el VM con `PlacesScope.of(context)` y envuelve la UI en `ListenableBuilder(listenable: vm, builder: ...)`.

`main.dart` instancia repos, VMs y servicios manualmente y los pasa por constructor. No hay locator ni `Provider` global. Para servicios sin estado de UI (`CameraService`, `LocationService`, `ShareService`) la inyección es directamente al constructor de la view que los usa, vía la closure del `GoRoute`.

### Modelo de datos

`Place` es una clase inmutable con `copyWith`, `toMap`, `fromMap`. La tabla `places` se crea en `AppDatabase._onCreate`. La versión del esquema vive en `AppDatabase._dbVersion` — al cambiar el schema, súbela y agrega `onUpgrade`.

## Convenciones

- **Sin `Map<String, dynamic>` en estado o firmas públicas.** Los maps existen solo en la frontera con sqflite (`toMap`/`fromMap`).
- **Tokens, no literales.** Spacings, radios, curvas y durations vienen de `framework/design/app_*`. No uses `EdgeInsets.all(16)` ni `Duration(milliseconds: 200)` en una view — agrega el token si falta.
- **Tema centralizado.** Material 3 con seed color en `AppTheme.light()`. Los componentes (botones, cards, inputs) heredan del tema; las views no estilizan a mano.
- **Widgets compartidos en `framework/widgets/`.** Si lo usa un solo feature, déjalo como `class _Widget` privado en el archivo de la view.
- **Una ruta = una view.** Las dependencias de servicios viajan por el closure del `GoRoute`, no por argumentos del path.

## Agregar un feature

1. `lib/app/<feature>/` con subcarpetas `model/`, `view/`, `viewmodel/` y, si toca DB, un `<feature>_repository.dart`.
2. Si necesitas exponer el VM al árbol de widgets, crea un `<feature>_scope.dart` análogo a `places_scope.dart`.
3. Registra rutas en `lib/app/router.dart`.
4. Si el feature toca disco, agrega tabla en `AppDatabase._onCreate` y sube `_dbVersion`.

## Limitaciones conocidas

- `sqflite` no corre en web; este proyecto está pensado para iOS/Android.
- Las imágenes se guardan por path en disco — borrar la app borra los archivos.
- Sin migraciones implementadas. Cambiar el schema requiere desinstalar o agregar `onUpgrade`.
