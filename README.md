# 🎴 TCG MyCard

**TCG MyCard** è un'applicazione moderna ed elegante sviluppata in Flutter per la gestione, il tracciamento e la valutazione del portafoglio di carte collezionabili (Trading Card Games) come **One Piece Card Game**, **Pokémon TCG**, **Magic: The Gathering**, **Yu-Gi-Oh!** e altri.

---

## ✨ Caratteristiche Principali

* ⚡ **Importazione da Link CardTrader**: Incolla semplicemente il link di una carta da CardTrader (es. `https://www.cardtrader.com/cards/...`) per estrarre automaticamente nome, codice, rarità, immagine ad alta definizione e valore di mercato attuale.
* 🔍 **Ricerca Automatica & Auto-Fill**: Ricerca rapida per codice carta (es. `OP17-119`, `OP10-082`) o per nome con aggiornamento automatico dei prezzi di listino.
* 📊 **Analytics & Statistiche Portafoglio**: Monitoraggio in tempo reale del valore totale della collezione con grafici interattivi (alimentati da `fl_chart`) per gioco e rarità.
* 📁 **Import & Export Massivo**: Importa ed esporta la tua collezione in formato **CSV** e **JSON** per backup locali o migrazioni rapide.
* 🎮 **Multi-Gioco integrato**: Supporto nativo per i principali giochi di carte con filtri per espansione, gioco, lingua e condizione.
* 🌙 **Interfaccia Dark Mode Moderna**: UI dinamica e reattiva curata nei minimi dettagli per un'esperienza utente premium su desktop (macOS, Windows, Linux), web e mobile (iOS, Android).

---

## 🛠️ Requisiti di Sistema

* **Flutter SDK**: `>= 3.12.0`
* **Dart SDK**: `>= 3.0.0`
* **Connessione Internet**: Per il recupero dei dati di mercato e delle immagini da CardTrader.

---

## 🚀 Installazione e Configurazione

### 1. Clona il repository
```bash
git clone https://github.com/tuo-username/tgc_mycard.git
cd tgc_mycard
```

### 2. Installa le dipendenze
```bash
flutter pub get
```

### 3. Configura il file `.env` (Opzionale per API CardTrader)
Crea o modifica il file `.env` nella radice del progetto per inserire il tuo token API personale di CardTrader:

```env
CARDTRADER_TOKEN=il_tuo_token_cardtrader_qui
```

> **Nota:** Se il token non è impostato o il file `.env` non è presente, l'applicazione utilizzerà automaticamente il motore di fallback integrato per la ricerca ed il recupero dei dati.

---

## 💻 Avvio dell'Applicazione

### Avvio in modalità Debug:
```bash
# Per macOS Desktop
flutter run -d macos

# Per Chrome / Web
flutter run -d chrome

# Per dispositivo mobile o emulatore collegato
flutter run
```

### Esecuzione dei Test:
```bash
flutter test
```

---

## 📂 Struttura del Progetto

```
lib/
├── models/             # Modelli dati (CardModel, ecc.)
├── providers/          # Gestione dello stato con Provider (PortfolioProvider)
├── services/           # Servizi di integrazione API, scraping CardTrader e Import/Export CSV
├── views/              # Schermate principali, dialoghi e componenti UI
└── main.dart           # Punto di ingresso dell'applicazione
```

---

## 📄 Licenza e Declinazione di Responsabilità

Questo progetto è distribuito sotto licenza **MIT**. Consulta il file [`LICENSE`](file:///Users/lucamiliciani/Developer/tgc_mycard/LICENSE) per maggiori dettagli.

> ⚠️ **Disclaimer (Declinazione di Responsabilità):**
> Il software viene fornito "COSÌ COM'È" ("AS IS"), senza alcuna garanzia esplicita o implicita. L'utente si assume l'intera responsabilità per l'utilizzo dell'applicazione, inclusi l'uso delle API di terze parti, il tracciamento dei valori finanziari delle carte e qualsiasi operazione sui propri dati. Gli autori e i contributori del progetto non potranno essere ritenuti responsabili per eventuali danni, perdite di dati o discrepanze nei prezzi di mercato.
