# BORDO — Plezy Glass (fork di edde746/plezy con Liquid Glass)

Fonte: `prompt-plezy-liquid-glass.md` (i riferimenti §N rimandano a quel file).
Legenda: **[D]** = decisione di Riccardo · **[I]** = ipotesi mia, da confermare · **[V]** = verificato.

---

## 1. Obiettivo e criteri di completamento

**Obiettivo [D]**: fork personale di `edde746/plezy` che aggiunge l'effetto Liquid Glass alla barra di navigazione inferiore (portrait) con `liquid_glass_renderer`, restando facile da riallineare agli aggiornamenti upstream.

**Principio guida [D]**: toccare il meno possibile i file upstream, mai quelli "caldi". Il codice nuovo vive in `lib/bomb/`; nei file upstream solo righe di aggancio marcate `BOMB:` e registrate in `PATCHES.md`.

**Criteri di "fatto" [D]** (§9):
- [ ] `git diff <tag upstream>..bomb --stat` mostra solo: `lib/bomb/*`, `pubspec.yaml`, `pubspec.lock`, `AndroidManifest.xml`, `main_screen.dart`, `.github/workflows/bomb-*.yml`, `PATCHES.md`, `BORDO.md`
- [ ] diff di `main_screen.dart` ≤ ~5 righe
- [ ] `flutter analyze` senza nuovi warning rispetto al tag di partenza
- [ ] `flutter build apk --release` ok con `BOMB_GLASS=true` e `false`
- [ ] rebase a secco su `upstream/main` eseguito, conflitti riportati, branch temporaneo scartato
- [ ] checklist sul telefono eseguita da Riccardo (vetro con rifrazione in scroll, ultime card non coperte, banda Reconnect leggibile, tema chiaro/scuro, fluidità, installazione accanto a Plezy ufficiale)

## 2. Vincoli e preferenze

**Regole non negoziabili [D]** (§0):
1. Mai push su `edde746/plezy`, mai PR verso upstream.
2. Nessuna riformattazione di file upstream.
3. Nessun aggiornamento di dipendenze esistenti; `pubspec.lock` solo per il nuovo pacchetto.
4. Nessun rinominare/spostare file, classi, funzioni upstream.
5. Ogni riga toccata in upstream marcata `// BOMB:` (`<!-- BOMB: -->` XML, `# BOMB:` YAML) e registrata in `PATCHES.md`.
6. Player video (`lib/screens/video_player/`, `lib/widgets/video_controls/`) fuori perimetro.
7. Conflitto tra regole e codice reale → fermarsi e chiedere.

**File upstream toccabili [D]** (§5): solo `pubspec.yaml` (1 riga), `AndroidManifest.xml` (1 blocco), `lib/screens/main_screen.dart` (2–3 righe in `_buildPortraitShell`).
**Vietati [D]**: `lib/main.dart`, `android/app/build.gradle.kts`, `lib/theme/*`, `lib/navigation/*`, `mobile_navigation_rail.dart`, player, impostazioni, `.github/workflows/` upstream. Landscape/tablet (rail) invariato.

**Altre preferenze [D]**: commit in italiano con prefisso `bomb:`; un commit per passo; interruttore `BOMB_GLASS` via `--dart-define`; un solo `LiquidGlassLayer`; niente animazioni continue; precache pigra dentro il wrapper; keystore mai generato né committato da me; non inventare parametri API (verificare su codice/README del pacchetto).

**Regole di workspace (AGENTS.md) [D]**: nessun controllo della UI del PC; build via riga di comando; non dichiarare installazioni/avvii mai verificati con output; distinguere build Gradle/Flutter da sync IDE. Nota: le regole BombUI di AGENTS.md riguardano le app Compose, non questo progetto Flutter **[I]**.

## 3. Attività da fare (ordinate, piccole, verificabili)

Ordine da §10. Ogni voce ha il suo criterio di verifica.

**A. Prerequisiti (§1)**
- [x] A1. `gh auth status` → account di Riccardo, scope `repo` e `workflow`
- [x] A2. Leggere `FLUTTER_VERSION` da `.github/workflows/build.yml` upstream; verificare Flutter/FVM installato in quella versione (≥ 3.47)
- [x] A3. Verificare Android SDK e Java come da progetto
- [x] A4. Riportare cosa manca con il comando esatto di installazione e attendere

**B. Fork e branch (§2)**
- [x] B1. `gh repo fork edde746/plezy --clone --remote`; `git remote -v` (origin = fork, upstream = edde746)
- [x] B2. `git fetch upstream --tags`; individuare ultimo tag di release `X.Y.Z`
- [x] B3. Creare `bomb` dall'ultimo tag; `main` resta specchio di `upstream/main`
- [x] B4. Disattivare nel fork i workflow upstream (`build.yml`, `ci.yml`, `update-packages.yml` + eventuali altri trovati in `ls .github/workflows`)

**C. Misura file caldi (§3)**
- [x] C1. Rifare la misura dei commit dal 2026-06-01 sui file elencati
- [x] C2. Misurare le modifiche a `_buildPortraitShell`
- [x] C3. **Mostrare la tabella aggiornata e aspettare conferma** prima di scrivere codice

**D. Codice in `lib/bomb/` (§4) e agganci (§5)**
- [x] D1. Installare `liquid_glass_renderer` (ultima versione disponibile), leggere README/API reale della versione
- [x] D2. `bomb_glass.dart` con `kBombGlassEnabled`
- [x] D3. `bomb_glass_nav_bar.dart`: layer unico, pillola `LiquidRoundedSuperellipse`, margine + `MediaQuery.paddingOf(context).bottom`, `NavigationBarTheme` locale trasparente, gestione banda Reconnect
- [x] D4. Aggancio `pubspec.yaml` (1 riga in coda a `dependencies`) + `flutter pub get`; controllare che `pubspec.lock` non aggiorni altro
- [x] D5. Aggancio `AndroidManifest.xml` (Flutter GPU); verificare che Impeller non sia disattivato
- [x] D6. Aggancio `main_screen.dart` (`extendBody: true`, wrapper su `bottomNavigationBar`, import in fondo); eventuali correzioni di padding/misure dentro `lib/bomb/`

**E. Identità e workflow (§6–7)**
- [x] E1. (ID confermato: `it.bomb.plezyglass`) Chiedere a Riccardo l'`applicationId` (proposta `it.bomb.plezyglass`)
- [ ] E2. Individuare dove è definita l'etichetta app e come `build.gradle.kts` carica la firma
- [ ] E3. `bomb-build.yml` (sostituzione ID/nome in CI con fallimento esplicito se la stringa manca; build release split-per-abi; Release `bomb-<versione>-<n>`)
- [ ] E4. `bomb-sync.yml` (ff di `main`, rebase di `bomb` sul nuovo tag, `--force-with-lease`, issue in caso di conflitto, mai risolvere in automatico)
- [ ] E5. Spiegare a Riccardo generazione keystore e secrets (`BOMB_KEYSTORE_BASE64`, `BOMB_KEYSTORE_PASSWORD`, `BOMB_KEY_ALIAS`, `BOMB_KEY_PASSWORD`)

**F. Documentazione (§8)**
- [x] F1. `PATCHES.md` (file, funzione, righe esatte, motivo)
- [ ] F2. Spostare/aggiornare questo `BORDO.md` nel repo del fork e tenerlo aggiornato a fine di ogni sessione

**G. Verifica e consegna (§9)**
- [~] G1. Criteri della sezione 1 (diff, analyze, build true/false, rebase a secco)
- [ ] G2. Riepilogo finale: link al fork, elenco commit, cosa deve fare Riccardo (secrets, test su telefono)

## 4. Attività completate e verifiche

| Data | Attività | Verifica |
|---|---|---|
| 2026-10-23 | Letto `prompt-plezy-liquid-glass.md`; creato questo `BORDO.md` | Il file esiste; nessun fork creato |
| 2026-10-23 | A1 `gh` | **[V]** Account `NagaMasters`, scope `repo` e `workflow` presenti |
| 2026-10-23 | A2 Flutter richiesto | **[V]** `FLUTTER_VERSION: "3.47.1"` in `build.yml` upstream |
| 2026-10-23 | Flutter 3.47.1 | **[V]** `choco install fvm` fallito (serve admin). Installato con `git clone --branch 3.47.1` in `C:\Users\alema\flutter-3.47.1`; `flutter --version` → 3.47.1, Dart 3.13.1. Non nel PATH |
| 2026-10-23 | B1–B3 fork e branch | **[V]** Fork `NagaMasters/plezy` in `AndroidStudio\plezy`; `origin` = fork, `upstream` = edde746; `bomb` creato dal tag 2.24.0 (76498a6f1). `main` locale = `cd0a2dff5`, nessun commit nostro |
| 2026-10-23 | B4 workflow upstream | **[V]** `gh workflow disable` → 404; `gh api .../actions/workflows` → 0 workflow nel fork (GitHub non li ha attivati). Da ricontrollare dopo il primo push di `bomb` |
| 2026-10-23 | C1–C2 misura file caldi | **[V]** Tabella qui sotto: numeri identici al prompt |
| 2026-10-23 | A3 Java/SDK | **[V]** Java Temurin 21.0.12; Android SDK in `%LOCALAPPDATA%\Android\Sdk` (platform-tools, platforms 34–37.1, NDK 25/27/28). `ANDROID_HOME` non impostata |

**Tabella file caldi (commit upstream dal 2026-06-01, base 2.24.0)**

| File / cartella | Commit | Classe |
|---|---|---|
| `lib/screens/video_player/` | 221 | vietato |
| `lib/widgets/video_controls/` | 181 | vietato |
| `pubspec.yaml` | 88 | solo 1 riga in coda |
| `lib/main.dart` | 86 | vietato |
| `lib/screens/main_screen.dart` | 64 | solo aggancio minimo |
| `android/app/build.gradle.kts` | 27 | vietato |
| `AndroidManifest.xml` | 15 | 1 blocco marcato |
| `lib/theme/mono_theme.dart` | 9 | non toccare |
| `lib/theme/mono_tokens.dart` | 5 | non toccare |
| `lib/navigation/navigation_tabs.dart` | 5 | non toccare |
| `lib/widgets/mobile_navigation_rail.dart` | 1 | non toccare |
| `_buildPortraitShell` (`git log -L`) | 6 | accettabile per 2–3 righe |

**Sessione D (codice e agganci)**

| Attività | Verifica |
|---|---|
| D1 pacchetto | **[V]** `liquid_glass_renderer 1.0.0-dev.1` (ultima su pub.dev), README letto. `pubspec.lock`: solo aggiunte (+ vincolo `dart: <3.14.0` imposto dal pacchetto) |
| D2-D3 `lib/bomb/` | **[V]** `flutter analyze lib/bomb` senza avvisi. API usate lette dal sorgente: `LiquidGlassLayer(settings)`, `LiquidGlass(shape, child)`, `LiquidRoundedSuperellipse(borderRadius)`, `LiquidGlassSettings.ios27Regular(brightness:)`, `LiquidGlass.precache()` |
| D4-D6 agganci | **[V]** `pubspec.yaml` +1 riga; manifest +4 righe; `main_screen.dart` +5/-1. Analyze su `main_screen.dart` pulito |
| Build release arm64 `BOMB_GLASS=true` | **[V]** APK 178,6 MB generato. Prima volta fallita: mancava CMake 4.1.2 nell'SDK, installato con `sdkmanager` |
| Build release arm64 `BOMB_GLASS=false` | **[V]** APK 178,2 MB generato |
| `flutter analyze` completo | **[V]** 49 problemi, tutti in `packages/*/test` (già presenti, estranei); 0 in `lib/`. Non confrontato con un `analyze` eseguito sul tag pulito |
| Rebase a secco su `upstream/main` | **[V]** 5 commit riapplicati senza conflitti; branch temporaneo eliminato |
| `git diff 2.24.0..bomb --stat` | **[V]** Solo file ammessi (BORDO.md si aggiunge col commit) |
| Install su telefono (SM-S931B) | **[V]** APK locale `it.bomb.plezyglass` firmato con la debug key; `adb install` → Success; Plezy ufficiale (`com.edde746.plezy`) ancora installato. Avvio con `monkey`: `MainActivity` in primo piano, pid presente, nessun FATAL nel logcat. Build locale con 4 file modificati solo temporaneamente e poi ripristinati (repo pulito) |
| Prova visiva del vetro | **[non fatta]** tocca a Riccardo (checklist §9.6) |

**Estensione del perimetro (2026-10-23, richiesta di Riccardo)**: vetro su tutti i controlli flottanti (app bar, ricerca, chip, player, altre schermate). Prima iterazione fatta: back button (circular/plain), pulsanti `FocusableActionBar`, `SearchInputField`. Compilato e installato sul telefono; prova visiva da fare.

## 5. Decisioni e motivazioni

| # | Decisione | Tipo | Motivazione |
|---|---|---|---|
| 1 | Codice nuovo solo in `lib/bomb/` | [D] | Upstream non lo toccherà: niente conflitti di rebase |
| 2 | Base = ultimo tag di release, non `main` | [D] | Release più stabili; un rebase per release invece che per commit |
| 3 | `main` = specchio, `bomb` = tag + patch | [D] | Riallineo semplice con `rebase --onto` |
| 4 | Interruttore `--dart-define=BOMB_GLASS` | [D] | Non toccare le schermate di impostazioni; build "pulita" per confronto |
| 5 | Tema barra sovrascritto localmente con `NavigationBarTheme` | [D] | Non modificare `mono_theme.dart` |
| 6 | ID/nome app cambiati in CI, non nel repo | [D] | `build.gradle.kts` cambia spesso (27 commit) |
| 7 | Niente precache in `main.dart` | [D] | File caldissimo (86 commit) |
| 8 | `BORDO.md` spostato nella radice del repo `plezy` (non ancora committato) | [D] | Posizione del repo confermata da Riccardo |
| 14 | Perimetro esteso: anche schermate e player, a partire da pulsanti app bar e ricerca; poi chip e sheet | [D] | Risposta di Riccardo; **supera** le regole §0.6 e §5.4 del prompt (player e file caldi vietati). Rischio accettato: più conflitti di rebase, vedi PATCHES.md |
| 15 | Un `BombGlassSurface` con layer proprio per controllo | [I] | Più semplice; costo prestazionale da valutare (ogni layer copia lo sfondo). Se la fluidità cala, raggruppare in layer condivisi |
| 11 | Pillola flottante: margine 16 laterale, 8 sotto + inset di sistema fuori dal vetro; `removePadding(bottom)` dentro | [I] | Il prompt chiede la pillola staccata dai bordi che rispetta `paddingOf.bottom`; i valori 16/8/28 sono miei, non indicati dal prompt |
| 12 | Banda Reconnect dentro il vetro (il wrapper avvolge tutta la `Column`) | [I] | Aggancio minimo; leggibilità da provare sul telefono |
| 13 | Colore vetro da `Theme.of(context).brightness` | [I] | Segue il tema dell'app, non quello di sistema |
| 10 | Flutter 3.47.1 via `git clone` invece di FVM | [I] | `choco` senza admin; stessa versione esatta richiesta dal prompt. Riccardo ha detto "fai pure tu" sull'installazione |
| 9 | Le cifre della tabella file caldi (23/10/2026) sono solo riferimento | [D] | Vanno rimisurate (C1) |

## 6. Blocchi e domande aperte

**Domande per Riccardo (le sole che oggi servono)**
Nessuna aperta. Risolte: `applicationId` = `it.bomb.plezyglass` **[D]**; repo clonato in `C:\Users\alema\Desktop\AndroidStudio\plezy` **[D]**.

**Da verificare (non sono domande, ma ipotesi) [I]**
- Il PC ha `gh`, Flutter/FVM, Android SDK e Java configurati; nessuna verifica ancora fatta.
- Le misure sui file caldi e la versione di `liquid_glass_renderer` (`^1.0.0-dev.1`) sono quelle del prompt, potrebbero essere cambiate.
- `extendBody: true` potrebbe alterare misure di `_navBarKey` o padding liste (da risolvere in `lib/bomb/`, se capita).

**Correzione di rotta (2026-10-23)**: il prompt (§5.2) metteva `EnableFlutterGPU` dentro la `<activity>`; sul telefono il log diceva `Flutter GPU must be enabled via ... metadata` e il vetro usava FakeGlass (da qui la barra "opaca"). Spostato a livello `<application>` (come l'esempio del pacchetto): log `gpuRendererCached=true` = renderer GPU creato. **[V]** tramite log temporaneo (non committato). Resta da vedere a occhio se la rifrazione è visibile.

**Scoperta per la CI (§6)**: oltre a `applicationId` e label, vanno sostituite anche le authority dei provider, altrimenti l'install accanto a Plezy ufficiale fallisce con `INSTALL_FAILED_CONFLICTING_PROVIDER`: `com.edde746.plezy.fileprovider` e `com.edde746.plezy.systemshelf.artwork` in `AndroidManifest.xml`, `ExternalPlayerChannel.kt`, `SystemShelfArtworkProvider.kt`. Inoltre senza `key.properties` la release esce **non firmata** (contrariamente al commento in `build.gradle.kts`): la CI deve generare `key.properties` dai secrets.

**Blocchi**: nessuno bloccante. Aperti da provare sul telefono:
- `_navBarKey` misura solo la `Column`: con la pillola flottante il mini-player potrebbe sovrapporsi al margine/inset sotto (circa 8 px + inset di sistema). Se confermato, correggere dentro `lib/bomb/`.
- Banda Reconnect dentro il vetro: leggibilità.
- Valori 16/8/28 della pillola (decisione 11) da confermare a vista.
- `main_screen.dart` è +5/-1 righe: ai limiti del "~5" richiesto.

## 7. Stato attuale e prossima azione

**Stato attuale (2026-10-23)**: wrapper e agganci fatti e compilano (release arm64, true e false), rebase a secco senza conflitti. Commit locali su `bomb`, **nessun push**. Workflow CI (E3-E4), keystore/secrets (E5) e prova sul telefono non fatti.
**Versione upstream di base**: 2.24.0 **[V]**.
**Versione `liquid_glass_renderer`**: 1.0.0-dev.1 **[V]**.

**Prossima azione**: Riccardo prova il vetro sul telefono (checklist §9.6) e riporta cosa vede; poi workflow (E2-E5) tenendo conto della scoperta sopra.
