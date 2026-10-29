# BORDO — Plezy Glass (fork di edde746/plezy con Liquid Glass)

Fonte: `prompt-plezy-liquid-glass.md` (i riferimenti §N rimandano a quel file). Mappa delle modifiche agli upstream: `PATCHES.md`.
Legenda: **[D]** = decisione di Riccardo · **[I]** = ipotesi o scelta mia, da confermare · **[V]** = verificato con un comando o un log.
Ultimo aggiornamento: 2026-10-29 sera (controllo degli aggiornamenti upstream dopo 2.25.0).

---

## 1. Obiettivo e criteri di completamento

**Obiettivo [D]**: fork personale di `edde746/plezy` (base iniziale: tag 2.24.0; dal 2026-10-27 tag 2.25.0, riallineato in automatico) con effetto Liquid Glass (`liquid_glass_renderer 1.0.0-dev.1`), facile da riallineare agli aggiornamenti upstream.
**Perimetro originale**: solo la barra inferiore portrait. **Perimetro attuale [D]** (scelta di Riccardo, 2026-10-23): tutti i controlli flottanti (app bar, ricerca, chip, player mobile, barra inferiore e rail orizzontale), più tre funzioni: titoli del player cliccabili, copertina di stagione nella hero, ridisegno delle barre.
**Principio guida [D]**: codice nuovo in `lib/bomb/`; nei file upstream solo agganci marcati `BOMB:` e registrati in `PATCHES.md`. Con l'estensione i file upstream toccati sono circa 20 (prima 3): più conflitti di rebase, rischio accettato.

**Criteri di "fatto"** (aggiornati al perimetro attuale):
- [x] `git diff 2.24.0..bomb --stat`: solo `lib/bomb/*`, i file elencati in `PATCHES.md`, `pubspec.*`, `AndroidManifest.xml`, `.github/workflows/bomb-*.yml`, `PATCHES.md`, `BORDO.md`. Qualsiasi altro file = errore
- [x] `flutter analyze` senza nuovi problemi rispetto al tag di partenza (49 sul tag 2.24.0 pulito, 49 sul nostro branch, tutti in `packages/*/test`)
- [x] `flutter build apk --release` ok con `BOMB_GLASS=true` **e** `false` (entrambe rifatte dopo le estensioni: arm64 178,6 MB e 178,2 MB)
- [x] rebase a secco su `upstream/main` (21 commit avanti al tag): prima del riposizionamento della riga di `pubspec.yaml` 1 conflitto banale (bump di `openwatchparty` sulla riga sopra); dopo, 0 conflitti. Risolto il conflitto, `pub get --enforce-lockfile` ok e `flutter analyze` pulito sui 23 file toccati
- [~] checklist sul telefono eseguita da Riccardo: vetro, tema chiaro, banda offline, mini-player e fluidità nel player confermati; installazione accanto a Plezy ufficiale confermata; Release 3 installata da Riccardo sopra la 2 (stessa firma); da confermare l'aggiornamento alla 2.25.0
- [x] workflow `bomb-build` e `bomb-sync` funzionanti, secrets caricati: il sync ha fatto da solo il rebase 2.24.0 → 2.25.0 il 2026-10-27 senza conflitti (caso "conflitto → issue" mai provato; issue attivate sul fork il 2026-10-29)

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
- [x] Barra inferiore ridisegnata a capsula (altezza 68, margini 16 laterali, raggio misurato, selezione = capsula dietro icona e testo, etichetta a 1 px dall'icona)
- [x] Rail orizzontale a capsula verticale (`mobile_navigation_rail.dart`, `BombGlassRail`)
- [x] Titoli del player cliccabili: serie → pagina della serie; riga episodio → pagina dell'episodio (`video_controls_header.dart`)
- [x] Copertina di stagione nella hero della home, solo in portrait (`discover_screen.dart`)
- [x] Sheet e menu (su telefono passano da `OverlaySheet`): pannello di vetro flottante, angoli 28, tinta massima, secondo l'immagine di riferimento di Riccardo (2026-10-25). Il vetro solo sui cerchi dell'intestazione è stato provato e annullato ("stona con il resto"). Da vedere a occhio sul telefono
- [ ] Barra del tempo del player, back della `BottomSheetHeader`, player desktop (`desktop_video_controls.dart`)
- [ ] Pulsanti senza vetro in altre schermate, se segnalati

**E. Identità e workflow (§6–7)**
- [x] E1 `applicationId` = `it.bomb.plezyglass` [D]
- [x] E2 etichetta (`android:label="Plezy"`, riga 35 del manifest) e firma (`android/key.properties` con `storeFile=upload-keystore.jks` relativo a `android/app`, come fa upstream)
- [x] E3 (eseguito su GitHub: run 40030660849 riuscito, Release `bomb-2.24.0-2`) `bomb-build.yml`: sostituire in CI `applicationId`, label e le authority (`com.edde746.plezy.fileprovider`, `com.edde746.plezy.systemshelf.artwork` in manifest + 2 file Kotlin), generare `key.properties` dai secrets, fallire se una stringa non c'è, pubblicare Release `bomb-<versione>-<n>`
- [x] E4 (eseguito su GitHub: run 40032174220 riuscito nel caso "già aggiornato"; il rebase su un tag nuovo e il caso con conflitti non sono mai stati provati) `bomb-sync.yml`: ff di `main`, rebase di `bomb` sul nuovo tag, `--force-with-lease`, issue in caso di conflitto, mai risolvere in automatico
- [x] E5 keystore generato da Riccardo (file `plezyglass.jks` nella sua cartella utente, backup suo); 5 secrets caricati: `BOMB_KEYSTORE_BASE64`, `BOMB_KEYSTORE_PASSWORD`, `BOMB_KEY_ALIAS`, `BOMB_KEY_PASSWORD`, `BOMB_PAT`. Spiegare a Riccardo keystore e secrets (`BOMB_KEYSTORE_BASE64`, `BOMB_KEYSTORE_PASSWORD`, `BOMB_KEY_ALIAS`, `BOMB_KEY_PASSWORD`)
- [x] E6 push di `bomb` sul fork `NagaMasters/plezy` con ok di Riccardo (2026-10-23); `bomb` impostato come branch predefinito; workflow upstream `Build`, `CI - Sanity Checks`, `Update Packages` disattivati. `main` non toccato (resta lo specchio, il sync lo allinea)

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
| 2026-10-23 | E2–E4 workflow | **[V]** YAML valido (`yaml.safe_load`); lo script di sostituzione di `bomb-build.yml` provato su una copia dei file: trova tutte le stringhe (1 `applicationId`, 1 label, 2 authority nel manifest, 1 per file Kotlin) e le cambia. **[non verificato]** esecuzione reale su GitHub Actions |
| 2026-10-23 | Primo run di `Bomb build` su GitHub (run 40029379003) | **[V]** riusciti: checkout, lettura di `FLUTTER_VERSION`, Java, Flutter, sostituzione di id/label/authority. Fallito come previsto al passo di firma per i secrets mancanti (errore chiaro). Non ancora provati: pub get, analyze, build APK, Release, `bomb-sync` |
| 2026-10-23 | `Bomb build` completo (run 40030660849) | **[V]** tutti i passi riusciti: pub get, analyze, APK per 3 architetture, Release `bomb-2.24.0-2` (arm64 101 MB, armeabi-v7a 97 MB, x86_64 110 MB). APK arm64 scaricato e controllato: firmato con `CN=Plezy Glass` (SHA-256 `02555cfe…a9dd2`), `package: it.bomb.plezyglass`, label `Plezy Glass`, versionName 2.24.0 |
| 2026-10-23 | `Bomb sync` (run 40032174220) | **[V]** riuscito: `BOMB_PAT` presente, fast-forward di `main`, base di `bomb` = ultimo tag = 2.24.0, nessuna azione. **[non provato]** rebase su un tag nuovo |
| 2026-10-24 | Verifiche finali G1 | **[V]** build `false` ok; analyze 49 = 49 col tag; rebase a secco: 1 conflitto banale in `pubspec.yaml`, il resto pulito, compila; diff vs tag: solo `lib/bomb/*` e i file elencati in `PATCHES.md`. Prove sul telefono di Riccardo: tema chiaro, banda offline, mini-player e fluidità del player ok |
| 2026-10-24 | Riga di `pubspec.yaml` spostata sotto `flutter_localizations` e fusa nel primo commit della dipendenza (storia di `bomb` riscritta, push forzato `--force-with-lease`; backup in `bomb-backup-prima-push-forzato`, locale e sul fork) | **[V]** contenuto identico al backup tranne quella riga; rebase a secco su `upstream/main` (21 commit avanti al tag): 0 conflitti su 27 commit. La Release `bomb-2.24.0-2` punta a un commit non più sul branch (resta scaricabile) |
| 2026-10-25 | Release `bomb-2.24.0-3` (sheet e menu in vetro) | **[V]** run riuscito; APK arm64 firmato con la stessa chiave della build 2 (SHA-256 `02555cfe…a9dd2`); hash diversi dalla build 2 (stessa dimensione per l'allineamento); `versionCode` 2155 uguale alla build 2 (Android lo accetta, ma non è crescente) |
| 2026-10-27 | Upstream pubblica 2.25.0: `Bomb sync` programmato fa il rebase da solo | **[V]** log: "Base attuale: 2.24.0, ultimo tag upstream: 2.25.0" → "Rebase riuscito"; push di `bomb` → `Bomb build` → Release `bomb-2.25.0-4`. APK arm64: stessa chiave, `it.bomb.plezyglass`, versionCode 2157, versionName 2.25.0. Sopra 2.25.0 restano 32 commit nostri, codice in `lib/bomb` e workflow identico a prima, 67 righe `BOMB` negli upstream come prima |
| 2026-10-29 | Copia locale riallineata al fork | **[V]** `bomb` locale = `origin/bomb` (il rebase in CI aveva cambiato gli ID); copia del vecchio stato in `bomb-locale-prima-di-2.25.0` (solo locale). Issue attivate sul fork (erano spente: il sync non avrebbe potuto segnalare conflitti) |
| 2026-10-29 | Controllo upstream dopo 2.25.0 | **[V]** nessun nuovo tag di release (ultimo 2.25.0, già la nostra base). `upstream/main` avanti di 9 commit non rilasciati: rebase a secco dei nostri 33 commit su `upstream/main` **senza conflitti**; `pub get --enforce-lockfile` ok; `flutter analyze` pulito sui 25 file toccati. Unico file in comune: `discover_screen.dart` (upstream mette `IgnorePointer` sui badge della barra azioni, lontano dal nostro aggancio sulla hero). Le 6 stringhe sostituite dalla CI ci sono ancora; `FLUTTER_VERSION` sempre 3.47.1. Riccardo ha installato `bomb-2.25.0-4` sopra la versione firmata: tutto a posto |
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
| 11 | Barra inferiore: capsula alta 68, margini 16 laterali e 12 sotto, selezione `onSurface` 12% con 3 px di margine verticale e 4 px di sbordo laterale, etichetta a 1 px dall'icona, raggio = metà dell'altezza misurata | [I] | Valori miei; Riccardo ha chiesto una forma più precisa e proporzionata |
| 19 | Selezione della barra = capsula dietro icona e testo insieme (non solo l'icona) | [D] | Scelta di Riccardo tra "togliere il testo" e "inglobarlo nella selezione"; l'indicatore di Material è spento |
| 12 | Banda Reconnect dentro il vetro | [I] | Aggancio minimo; leggibilità da provare offline |
| 13 | Colore del vetro dal tema dell'app (`Theme.brightness`) | [I] | Segue il tema scelto nell'app |
| 14 | Un layer per controllo (`BombGlassSurface`); la riga azioni è un solo modulo; chip della striscia in un layer condiviso | [I] | Semplicità; se cala la fluidità, raggruppare |
| 15 | Ombra di esempio del README del pacchetto sul vetro | [I] | Il vetro su sfondo piatto era quasi invisibile |
| 16 | Comandi del player: superficie "vetro" senza campionamento (gradiente bianco 20%→5%, bordo 30%) invece del preset `clear` | [I] | Il preset `clear` restava opaco: dietro c'è solo trasparenza; valori di alfa miei |
| 17 | Titoli del player: chiudere con `onBack` (progresso e teardown regolari) e poi aprire la pagina | [I] | Evita video che continua dietro; la pagina sotto può risultare duplicata |
| 18 | Copertina di stagione solo con hero verticale (aspect < 1.0), con fallback agli sfondi | [I] | Un poster 2:3 in un hero largo verrebbe tagliato |

## 6. Blocchi e domande aperte

**Scoperte sui workflow (2026-10-23)**
- I `schedule` girano solo dal branch predefinito: `bomb-sync.yml` sta su `bomb`, quindi `bomb` deve diventare il branch predefinito del fork (`gh repo edit --default-branch bomb`). `main` resta lo specchio di upstream.
- Il `GITHUB_TOKEN` non può modificare file in `.github/workflows` e i suoi push non fanno partire altri workflow: il sync usa un token personale nel secret `BOMB_PAT` (scope `repo` e `workflow`), così il push di `bomb` fa partire `bomb-build`.
- Dopo il primo push vanno disattivati nel fork i workflow upstream: `update-packages.yml` parte su `release: published` (le nostre Release lo attiverebbero), `ci.yml` su push e PR verso `main`, `build.yml` solo a mano.
- Le Release firmate in CI hanno firma diversa dalla build locale di prova (chiave di debug): per installarle serve prima disinstallare Plezy Glass locale (i dati dell'app si perdono; il Plezy ufficiale non è coinvolto).
- La build di CI non usa `ENABLE_UPDATE_CHECK`, `ENABLE_SENTRY` e `ENABLE_DONATIONS` di upstream: l'app non controlla aggiornamenti dalle Release di edde746 e non invia segnalazioni a Sentry.

**Correzioni di rotta rispetto al prompt**
- §5.2: `EnableFlutterGPU` va a livello `<application>`, non dentro l'`<activity>`: nell'activity il motore lo ignorava e il vetro usava FakeGlass (barra opaca). Corretto e verificato.
- §6: oltre a `applicationId` e label vanno sostituite le authority dei provider, altrimenti l'install accanto a Plezy ufficiale fallisce (`INSTALL_FAILED_CONFLICTING_PROVIDER`). Inoltre senza `key.properties` la release esce **non firmata**, contrariamente al commento in `build.gradle.kts`.

**Da provare sul telefono**
- Mini-player sovrapposto alla capsula in basso (`_navBarKey` misura solo la `Column`).
- Banda Reconnect leggibile con l'app offline.
- Tema chiaro; fluidità nel player con più layer attivi.
- Valori della capsula (decisione 11).
- Rail orizzontale: i contenuti stanno accanto, non dietro, quindi poca rifrazione.

**Da fare alla prossima release upstream (oggi solo su `upstream/main`)**
- Nuovo pulsante di sblocco dello schermo nel player (`lib/widgets/video_controls/widgets/screen_lock_overlay.dart`, commit `1fc16b6c1`): pillola nera al 60% con angoli 28 sopra il video, stona con i nostri comandi del player. Quando arriva nella base, aggancio di 1-2 righe con `BombGlassSurface(clear: true)` per lo stato normale (lo stato "armato" bianco resta).
- Nuova scheda Generi nelle librerie (commit `ffe7d792d`): il suo chip passa da `FocusableTabChip`, quindi avrà già il vetro; la griglia dei generi non è un elemento flottante. Da guardare a occhio.

**Rischi**
- File upstream molto attivi toccati (`discover_screen.dart` 61 commit, `video_controls_header.dart` e altri nel player): conflitti attesi a ogni rebase.
- Scambio Brotherhood/2003 visto una volta: non riprodotto, causa ignota.

**Rami di sicurezza da cancellare quando Riccardo è tranquillo**: `bomb-backup-prima-push-forzato` (locale e fork), `bomb-locale-prima-di-2.25.0` (locale). Release vecchie `bomb-2.24.0-2` e `-3` cancellabili.

**Domande aperte per Riccardo**
- Come vuole le sheet e i menu a comparsa (vetro a tutta sheet o solo header/pulsanti)?
- Ok al primo push di `bomb` e `main`, a impostare `bomb` come branch predefinito del fork e a disattivare i workflow upstream?
- Genera lui il keystore e il token `BOMB_PAT` (comandi forniti in chat)?

## 7. Stato attuale e prossima azione

**Stato (2026-10-29)**: fork pubblicato e in manutenzione automatica. Base upstream 2.25.0 (riallineata da sola il 2026-10-27). Vetro su: barre di navigazione (capsula in basso con selezione che include icona e testo, rail orizzontale), controlli flottanti, ricerca, chip, riga azioni del dettaglio, sheet e menu (pannello flottante), comandi del player (superficie trasparente non campionata). Funzioni: titoli del player cliccabili, copertina di stagione nella hero. Ultima Release: `bomb-2.25.0-4`. Verifiche G1 fatte (build true/false, analyze = tag, rebase a secco pulito).
**Base upstream**: 2.24.0 [V]. **liquid_glass_renderer**: 1.0.0-dev.1 [V].

**Prossima azione**: Riccardo installa `bomb-2.25.0-4` sopra la versione firmata e conferma che dati e login restano. Facoltativo: `versionCode` crescente a ogni Release (1 riga in `bomb-build.yml`), barra del tempo del player, player desktop, rail orizzontale con rifrazione.
