# BORDO — Plezy Glass (fork di edde746/plezy con Liquid Glass)

Fonte: `prompt-plezy-liquid-glass.md` (i riferimenti §N rimandano a quel file). Mappa delle modifiche agli upstream: `PATCHES.md`.
Legenda: **[D]** = decisione di Riccardo · **[I]** = ipotesi o scelta mia, da confermare · **[V]** = verificato con un comando o un log.
Ultimo aggiornamento: 2026-10-23, dopo il commit `a3c10429d`.

---

## 1. Obiettivo e criteri di completamento

**Obiettivo [D]**: fork personale di `edde746/plezy` (base: tag 2.24.0) con effetto Liquid Glass (`liquid_glass_renderer 1.0.0-dev.1`), facile da riallineare agli aggiornamenti upstream.
**Perimetro originale**: solo la barra inferiore portrait. **Perimetro attuale [D]** (scelta di Riccardo, 2026-10-23): tutti i controlli flottanti (app bar, ricerca, chip, player mobile, barra inferiore e rail orizzontale), più tre funzioni: titoli del player cliccabili, copertina di stagione nella hero, ridisegno delle barre.
**Principio guida [D]**: codice nuovo in `lib/bomb/`; nei file upstream solo agganci marcati `BOMB:` e registrati in `PATCHES.md`. Con l'estensione i file upstream toccati sono circa 20 (prima 3): più conflitti di rebase, rischio accettato.

**Criteri di "fatto"** (aggiornati al perimetro attuale):
- [ ] `git diff 2.24.0..bomb --stat`: solo `lib/bomb/*`, i file elencati in `PATCHES.md`, `pubspec.*`, `AndroidManifest.xml`, `.github/workflows/bomb-*.yml`, `PATCHES.md`, `BORDO.md`. Qualsiasi altro file = errore
- [ ] `flutter analyze` senza nuovi problemi rispetto al tag di partenza (oggi: 49 in `packages/*/test`, già presenti; non confrontato con un `analyze` sul tag pulito)
- [ ] `flutter build apk --release` ok con `BOMB_GLASS=true` **e** `false` (la prova `false` è precedente alle estensioni: da rifare)
- [ ] rebase a secco su `upstream/main` senza conflitti (fatto sui primi 5 commit, da rifare con tutti)
- [ ] checklist sul telefono eseguita da Riccardo: vetro visibile, ultime card non coperte, banda Reconnect leggibile, tema chiaro e scuro, fluidità (soprattutto nel player), mini-player non sovrapposto, installazione accanto a Plezy ufficiale
- [ ] workflow `bomb-build` e `bomb-sync` funzionanti, secrets caricati

## 2. Vincoli e preferenze

**Regole non negoziabili [D]**: 1) mai push su `edde746/plezy`, mai PR verso upstream; 2) nessuna riformattazione dei file upstream; 3) nessun aggiornamento di dipendenze esistenti; 4) nessun rinominare/spostare file, classi o funzioni upstream; 5) ogni riga toccata in upstream marcata `BOMB:` e registrata in `PATCHES.md`; 7) conflitto tra regole e codice reale → fermarsi e chiedere.
**Regola cambiata [D]**: la 6 (player fuori perimetro) e il divieto di toccare `lib/screens/*`, `lib/widgets/*`, `lib/focus/*` sono superati dalla scelta di Riccardo del 2026-10-23. Restano vietati: `lib/main.dart`, `android/app/build.gradle.kts`, `lib/theme/*`, `.github/workflows/` upstream.
**Altre preferenze [D]**: commit in italiano con prefisso `bomb:`; un commit per passo; interruttore `BOMB_GLASS`; precache pigra dentro `lib/bomb/`; keystore mai generato né committato da me; non inventare parametri API; nessun controllo della UI del PC; non dichiarare install/avvii non verificati (AGENTS.md).

## 3. Attività da fare

**A. Prerequisiti** — [x] A1 gh · [x] A2 Flutter richiesto (3.47.1) · [x] A3 Java/SDK · [x] A4 report
**B. Fork e branch** — [x] B1 fork · [x] B2 tag · [x] B3 `bomb` da 2.24.0 · [x] B4 workflow upstream (nessuno registrato nel fork; da ricontrollare dopo il primo push)
**C. Misura file caldi** — [x] C1 · [x] C2 · [x] C3 confermata da Riccardo
**D. Barra inferiore e agganci** — [x] D1 pacchetto · [x] D2 interruttore · [x] D3 wrapper · [x] D4 pubspec · [x] D5 manifest (poi corretto, vedi §6) · [x] D6 `main_screen.dart`

**D2. Estensione (richiesta di Riccardo)**
- [x] Back button, tutti gli stili (`app_bar_back_button.dart`)
- [x] Action bar in un solo modulo, con opzione `bombGlass` (`focusable_action_bar.dart`; spento in `mini_player.dart` e `queue_sheet.dart`)
- [x] Barra di ricerca (`search_input_field.dart`)
- [x] Chip di filtro e di scelta (`focus_builders.dart`; striscia dei tab con un layer condiviso)
- [x] Riga azioni della schermata film/serie con pulsanti traslucidi (`media_detail/action_buttons.dart`)
- [x] Back del telecomando (`mobile_remote_screen.dart`)
- [x] Player mobile: pulsanti circolari, back, gruppo tracce/capitoli, in vetro `clear`
- [x] Barra inferiore ridisegnata a capsula (altezza 64, raggio misurato, indicatore a capsula)
- [x] Rail orizzontale a capsula verticale (`mobile_navigation_rail.dart`, `BombGlassRail`)
- [x] Titoli del player cliccabili: serie → pagina della serie; riga episodio → pagina dell'episodio (`video_controls_header.dart`)
- [x] Copertina di stagione nella hero della home, solo in portrait (`discover_screen.dart`)
- [ ] Sheet e menu a comparsa (`overlay_sheet.dart`): da decidere come con Riccardo
- [ ] Barra del tempo del player, back della `BottomSheetHeader`, player desktop (`desktop_video_controls.dart`)
- [ ] Pulsanti senza vetro in altre schermate, se segnalati

**E. Identità e workflow (§6–7)**
- [x] E1 `applicationId` = `it.bomb.plezyglass` [D]
- [ ] E2 etichetta app (`android:label="Plezy"`, riga 35 del manifest) e firma (`key.properties`) — già letti, da trasferire nel workflow
- [ ] E3 `bomb-build.yml`: sostituire in CI `applicationId`, label e le authority (`com.edde746.plezy.fileprovider`, `com.edde746.plezy.systemshelf.artwork` in manifest + 2 file Kotlin), generare `key.properties` dai secrets, fallire se una stringa non c'è, pubblicare Release `bomb-<versione>-<n>`
- [ ] E4 `bomb-sync.yml`: ff di `main`, rebase di `bomb` sul nuovo tag, `--force-with-lease`, issue in caso di conflitto, mai risolvere in automatico
- [ ] E5 spiegare a Riccardo keystore e secrets (`BOMB_KEYSTORE_BASE64`, `BOMB_KEYSTORE_PASSWORD`, `BOMB_KEY_ALIAS`, `BOMB_KEY_PASSWORD`)
- [ ] E6 primo push di `bomb` (e `main` come specchio) sul fork `NagaMasters/plezy` — solo con ok di Riccardo

**F. Documentazione** — [x] F1 `PATCHES.md` · [x] F2 `BORDO.md` nel repo, committato e riscritto il 2026-10-23
**G. Verifica e consegna** — [ ] G1 criteri della sezione 1 · [ ] G2 riepilogo finale (link al fork, commit, cosa fa Riccardo)

## 4. Attività completate e verifiche

| Data | Attività | Verifica |
|---|---|---|
| 2026-10-23 | A1–A3 | **[V]** `gh` come `NagaMasters` con scope `repo` e `workflow`; Flutter richiesto 3.47.1; Java Temurin 21.0.12; Android SDK con piattaforme 34–37.1 |
| 2026-10-23 | Flutter 3.47.1 | **[V]** `choco install fvm` fallito (serve admin); installato con `git clone --branch 3.47.1` in `C:\Users\alema\flutter-3.47.1` (non nel PATH) |
| 2026-10-23 | CMake 4.1.2 | **[V]** mancava nell'SDK, la build falliva; installato con `sdkmanager` |
| 2026-10-23 | B1–B3 | **[V]** `origin` = `NagaMasters/plezy`, `upstream` = edde746; `bomb` da 2.24.0 (76498a6f1) |
| 2026-10-23 | C | **[V]** numeri identici al prompt (tabella sotto) |
| 2026-10-23 | D1–D6 | **[V]** analyze pulito su `lib/bomb` e sui file toccati; build release arm64 `true` e `false` riuscite (prima delle estensioni) |
| 2026-10-23 | Install sul telefono SM-S931B | **[V]** `adb install` Success, `MainActivity` in primo piano, nessun FATAL; Plezy ufficiale ancora installato. Build locale con `applicationId`/label/authority cambiati solo temporaneamente, firma debug (script nello scratchpad, non nel repo) |
| 2026-10-23 | Flutter GPU | **[V]** log temporaneo: dopo lo spostamento a livello `<application>`, `gpuRendererCached=true` |
| 2026-10-23 | Player e vetro | **[V]** dal codice (`PlayerSurfaceHost.kt`): il video sta in `SurfaceView` nativi sotto Flutter, non campionabili; per questo i comandi usano il preset `clear` |
| 2026-10-23 | Indagine Fullmetal Alchemist | **[V]** log temporaneo (non committato): a Plezy Glass arrivano gli ID giusti (Brotherhood 40918/40971, 2003 47640); lo scambio non si è più ripetuto, causa non identificata. Su BOMBFLIX Brotherhood è in due librerie (2 e 3) |
| 2026-10-23 | Prova visiva | **[non fatta da me]** Riccardo ha visto vetro, forme, rail e player e ha confermato "così va bene" su più punti; mancano tema chiaro e le verifiche di §1 |

**Tabella file caldi (commit upstream dal 2026-06-01, base 2.24.0)**

| File / cartella | Commit |
|---|---|
| `lib/screens/video_player/` | 221 |
| `lib/widgets/video_controls/` | 181 |
| `pubspec.yaml` | 88 |
| `lib/main.dart` | 86 |
| `lib/screens/main_screen.dart` | 64 |
| `lib/screens/discover_screen.dart` | 61 |
| `lib/screens/libraries/libraries_screen.dart` | 30 |
| `android/app/build.gradle.kts` | 27 |
| `lib/widgets/overlay_sheet.dart` | 17 |
| `AndroidManifest.xml` | 15 |
| `lib/focus/focusable_action_bar.dart` | 8 |
| `lib/widgets/focus_builders.dart` | 5 |
| `app_bar_back_button.dart`, `desktop_app_bar.dart` | 4 |
| `focusable_filter_chip.dart` | 2 |
| `mobile_navigation_rail.dart` | 1 |

## 5. Decisioni e motivazioni

| # | Decisione | Tipo | Motivazione |
|---|---|---|---|
| 1 | Codice nuovo solo in `lib/bomb/` | [D] | Upstream non lo toccherà |
| 2 | Base = ultimo tag di release (2.24.0) | [D] | Un rebase per release |
| 3 | `main` specchio, `bomb` = tag + patch | [D] | Riallineo con `rebase --onto` |
| 4 | Interruttore `--dart-define=BOMB_GLASS` | [D] | Build "pulita" per confronto |
| 5 | Tema delle barre sovrascritto in locale | [D] | Non toccare `lib/theme/*` |
| 6 | ID, label e authority cambiati in CI, non nel repo | [D] | `build.gradle.kts` cambia spesso (27 commit) |
| 7 | `applicationId` = `it.bomb.plezyglass` | [D] | Scelta di Riccardo |
| 8 | Repo in `C:\Users\alema\Desktop\AndroidStudio\plezy` | [D] | Scelta di Riccardo |
| 9 | Perimetro esteso a schermate e player; prima app bar e ricerca, poi chip e sheet | [D] | Richiesta di Riccardo; supera le regole §0.6 e §5.4 del prompt |
| 10 | Flutter 3.47.1 via `git clone` invece di FVM | [I] | `choco` richiede admin; stessa versione |
| 11 | Barra inferiore: capsula alta 64, margini 24 laterali e 12 sotto, indicatore `onSurface` 12%, raggio = metà dell'altezza misurata | [I] | Valori miei; Riccardo ha chiesto una forma più precisa e proporzionata |
| 12 | Banda Reconnect dentro il vetro | [I] | Aggancio minimo; leggibilità da provare offline |
| 13 | Colore del vetro dal tema dell'app (`Theme.brightness`) | [I] | Segue il tema scelto nell'app |
| 14 | Un layer per controllo (`BombGlassSurface`); la riga azioni è un solo modulo; chip della striscia in un layer condiviso | [I] | Semplicità; se cala la fluidità, raggruppare |
| 15 | Ombra di esempio del README del pacchetto sul vetro | [I] | Il vetro su sfondo piatto era quasi invisibile |
| 16 | Comandi del player in vetro `clear` | [I] | Il video non è campionabile dal vetro: poca tinta, resta il bordo |
| 17 | Titoli del player: chiudere con `onBack` (progresso e teardown regolari) e poi aprire la pagina | [I] | Evita video che continua dietro; la pagina sotto può risultare duplicata |
| 18 | Copertina di stagione solo con hero verticale (aspect < 1.0), con fallback agli sfondi | [I] | Un poster 2:3 in un hero largo verrebbe tagliato |

## 6. Blocchi e domande aperte

**Correzioni di rotta rispetto al prompt**
- §5.2: `EnableFlutterGPU` va a livello `<application>`, non dentro l'`<activity>`: nell'activity il motore lo ignorava e il vetro usava FakeGlass (barra opaca). Corretto e verificato.
- §6: oltre a `applicationId` e label vanno sostituite le authority dei provider, altrimenti l'install accanto a Plezy ufficiale fallisce (`INSTALL_FAILED_CONFLICTING_PROVIDER`). Inoltre senza `key.properties` la release esce **non firmata**, contrariamente al commento in `build.gradle.kts`.

**Da provare sul telefono**
- Mini-player sovrapposto alla capsula in basso (`_navBarKey` misura solo la `Column`).
- Banda Reconnect leggibile con l'app offline.
- Tema chiaro; fluidità nel player con più layer attivi.
- Valori della capsula (decisione 11).
- Rail orizzontale: i contenuti stanno accanto, non dietro, quindi poca rifrazione.

**Rischi**
- File upstream molto attivi toccati (`discover_screen.dart` 61 commit, `video_controls_header.dart` e altri nel player): conflitti attesi a ogni rebase.
- Scambio Brotherhood/2003 visto una volta: non riprodotto, causa ignota.

**Domande aperte per Riccardo**
- Come vuole le sheet e i menu a comparsa (vetro a tutta sheet o solo header/pulsanti)?
- Va bene fare il primo push del branch `bomb` sul fork?
- Vuole generare lui il keystore con i comandi che gli darò?

## 7. Stato attuale e prossima azione

**Stato**: barra inferiore e rail orizzontale a capsula; controlli flottanti, chip e player mobile in vetro; titoli del player cliccabili; copertina di stagione nella hero. Tutto compila e gira sul telefono (ultimo commit `4bef59ab7`, build pulita installata). 16 commit locali su `bomb` rispetto al tag 2.24.0, **nessun push**. Workflow CI, keystore e secrets non fatti.
**Base upstream**: 2.24.0 [V]. **liquid_glass_renderer**: 1.0.0-dev.1 [V].

**Prossima azione**: Riccardo risponde sulle domande aperte; poi E2–E5 (workflow e secrets), E6 (push), le rifiniture grafiche rimaste e G1 (criteri finali, compresa la build con `BOMB_GLASS=false` e il rebase a secco aggiornati).
