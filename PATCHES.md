# PATCHES — modifiche ai file upstream (base: tag 2.24.0)

Mappa da seguire quando un rebase va in conflitto. Ogni riga toccata è marcata `BOMB:`.

## `pubspec.yaml`
- In coda a `dependencies:` (dopo `openwatchparty`): `liquid_glass_renderer: ^1.0.0-dev.1 # BOMB: liquid glass`.
- `pubspec.lock`: solo righe aggiunte dal `pub get` (liquid_glass_renderer 1.0.0-dev.1 e transitive: data_assets, equatable, flutter_gpu, flutter_gpu_shaders, flutter_shaders, motor, ...) più il vincolo SDK `dart: ">=3.13.0 <3.14.0"` imposto dal pacchetto. Nessun altro pacchetto aggiornato. In caso di conflitto: rigenerare con `flutter pub get`.

## `android/app/src/main/AndroidManifest.xml`
- Dentro `<application>`, subito dopo `<uses-library android:name="android.car" .../>`: blocco `<!-- BOMB: Flutter GPU ... -->` con meta-data `io.flutter.embedding.android.EnableFlutterGPU` = `true` (4 righe). Deve stare a livello application: dentro l'`<activity>` (come diceva il prompt) il motore lo ignora e il vetro ripiega su FakeGlass.
- Impeller: `FlutterRendererPolicy.kt` lo sceglie per i telefoni (Skia solo per TV vecchie, NVIDIA, Huawei/HONOR, e-waste). Non toccato.

## `lib/screens/main_screen.dart`
Funzione `_buildPortraitShell`:
1. In fondo agli import: `import '../bomb/bomb_glass_nav_bar.dart'; // BOMB: liquid glass`.
2. `extendBody: true, // BOMB: ...` come prima proprietà dello `Scaffold`.
3. `bottomNavigationBar: Column(` diventa `bottomNavigationBar: BombGlassNavBar( // BOMB` + riga `child: Column(`.
4. Chiusura: riga `), // BOMB` dopo la `),` della `Column`.
Il layout landscape, `_buildBottomNavigationBar` e `_navBarKey` non sono toccati.

## Estensione del vetro ai controlli flottanti (decisione di Riccardo, 2026-10-23)
Widget condivisi toccati; ogni riga marcata `// BOMB`. Codice nuovo: `lib/bomb/bomb_glass_surface.dart` (`BombGlassSurface`, un layer per controllo).

### `lib/widgets/app_bar_back_button.dart`
- 2 import in coda.
- Stile `circular`: colori base/hover resi trasparenti / bianco 12% quando il vetro è attivo.
- Il figlio del `AnimatedContainer` è avvolto in `BombGlassSurface.circle(diameter: 40)` per gli stili `circular` e `plain`; lo stile `video` è invariato.

### `lib/focus/focusable_action_bar.dart`
- 1 import in coda.
- La riga `Row` di tutte le azioni è avvolta in un solo `BombGlassSurface(borderRadius: 24)` (in `build`, dentro l'`AnimatedOpacity`): un unico modulo di vetro per tutti i pulsanti, anche quelli con `child`/`builder` custom (Watch Together, Companion Remote, menu profilo). Un solo pulsante = pillola tonda.

### `lib/widgets/search_input_field.dart`
- 2 import in coda.
- `Stack` avvolto in `BombGlassSurface(borderRadius: 24)`; `fillColor` della decorazione trasparente quando il vetro è attivo (tocca solo questo campo, non `pillInputDecoration`).

### Correzioni e chip (2026-10-23)
- `lib/bomb/bomb_glass_surface.dart`: `BombGlassSurface` ora ha anche `.auto` (usa il layer condiviso, con `tint` opzionale) e `BombGlassLayer` (un layer per più forme); ombra del README del pacchetto per leggere il vetro su sfondi piatti.
- `lib/focus/focusable_action_bar.dart`: parametro `bombGlass` (default `true`); `false` in `lib/widgets/music/mini_player.dart` e `lib/screens/music/queue_sheet.dart` (barre già dentro una card/sheet).
- `lib/screens/media_detail/action_buttons.dart` (+ import in `lib/screens/media_detail_screen.dart`, file `part of`): sfondi dei pulsanti trasparenti con vetro attivo (`idleBg`, `FilledButton.styleFrom`, `IconButton.styleFrom`) e `foregroundColor` = `onSurface` per Play, così si vede il vetro della riga.
- `lib/screens/companion_remote/mobile_remote_screen.dart`: `AppBar` con `automaticallyImplyLeading: false` + `AppBarBackButton(plain)` quando `Navigator.canPop`; import in coda.
- `lib/widgets/focus_builders.dart` (`buildFocusableChip`): parametro `bombTinted`; il contenuto è avvolto in `BombGlassSurface.auto` con `AnimatedContainer` trasparente. Chiamanti: `focusable_filter_chip.dart` (`bombTinted: showFocus`) e `focusable_tab_chip.dart` (`bombTinted: isHighlighted`; `TabChipStrip` avvolge la riga in `BombGlassLayer`).
