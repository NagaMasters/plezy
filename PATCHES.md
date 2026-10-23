# PATCHES — modifiche ai file upstream (base: tag 2.24.0)

Mappa da seguire quando un rebase va in conflitto. Ogni riga toccata è marcata `BOMB:`.

## `pubspec.yaml`
- In coda a `dependencies:` (dopo `openwatchparty`): `liquid_glass_renderer: ^1.0.0-dev.1 # BOMB: liquid glass`.
- `pubspec.lock`: solo righe aggiunte dal `pub get` (liquid_glass_renderer 1.0.0-dev.1 e transitive: data_assets, equatable, flutter_gpu, flutter_gpu_shaders, flutter_shaders, motor, ...) più il vincolo SDK `dart: ">=3.13.0 <3.14.0"` imposto dal pacchetto. Nessun altro pacchetto aggiornato. In caso di conflitto: rigenerare con `flutter pub get`.

## `android/app/src/main/AndroidManifest.xml`
- Nella `<activity android:name=".PlezyActivity">`, subito dopo il meta-data `NormalTheme`: blocco `<!-- BOMB: Flutter GPU per liquid_glass_renderer -->` con meta-data `io.flutter.embedding.android.EnableFlutterGPU` = `true` (4 righe).
- Impeller: `FlutterRendererPolicy.kt` lo sceglie per i telefoni (Skia solo per TV vecchie, NVIDIA, Huawei/HONOR, e-waste). Non toccato.

## `lib/screens/main_screen.dart`
Funzione `_buildPortraitShell`:
1. In fondo agli import: `import '../bomb/bomb_glass_nav_bar.dart'; // BOMB: liquid glass`.
2. `extendBody: true, // BOMB: ...` come prima proprietà dello `Scaffold`.
3. `bottomNavigationBar: Column(` diventa `bottomNavigationBar: BombGlassNavBar( // BOMB` + riga `child: Column(`.
4. Chiusura: riga `), // BOMB` dopo la `),` della `Column`.
Il layout landscape, `_buildBottomNavigationBar` e `_navBarKey` non sono toccati.
