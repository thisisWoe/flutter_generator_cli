# **Flutter Starter CLI**

Una CLI per inizializzare progetti Flutter con configurazioni predefinite e dipendenze selezionate dall’utente.


## **Descrizione**

flutter_starter_cli è uno strumento da linea di comando che semplifica la creazione di nuovi progetti Flutter utilizzando very_good_cli e permette di aggiungere automaticamente alcune dipendenze comuni come go_router, json_serializable e dio.

## **Requisiti**

•  **Dart SDK**: Versione 3.5.3 o successiva.

•  **Flutter SDK**: Assicurati di avere Flutter installato e configurato nel tuo PATH.

•  **very_good_cli**: Deve essere installato globalmente. Puoi installarlo con:

```
dart pub global activate very_good_cli
```

## **Installazione**

**1. Clonare il Repository**
Puoi clonare il repository dal seguente link:
```
git clone https://github.com/thisisWoe/flutter_generator_cli.git
```
**2. Installare le Dipendenze**
Naviga nella directory del progetto ed esegui:
```
cd flutter_generator_cli
dart pub get
```
**3. Attivare la CLI Globalmente**
Per rendere la CLI accessibile da qualsiasi posizione nel terminale, attivala globalmente:
```
dart pub global activate --source path .
```
**4. Aggiungere la Directory degli Eseguibili Globali al PATH**
Per poter eseguire il comando flutter_starter da qualsiasi posizione, devi aggiungere la directory degli eseguibili globali di Dart al tuo PATH.
**Su macOS/Linux**
Aggiungi la seguente linea al tuo file ~/.bashrc, ~/.bash_profile o ~/.zshrc:
```
export PATH="$PATH":"$HOME/.pub-cache/bin"
```
Quindi, ricarica la configurazione della shell:
```
source ~/.bashrc
```
O, se usi zsh:
```
source ~/.zshrc
```
**Su Windows**
1.  Apri le impostazioni delle variabili d’ambiente:

•  Premi Win + X e seleziona ***Sistema***.

•  Clicca su ***Impostazioni di sistema avanzate***.

•  Clicca su ***Variabili d’ambiente***.

2.  Nella sezione ***Variabili utente*** o ***Variabili di sistema***, trova e seleziona la variabile Path, quindi clicca su ***Modifica***.

3.  Aggiungi una nuova voce con il percorso:
```
%USERPROFILE%\AppData\Local\Pub\Cache\bin
```
4.  Salva le modifiche e riavvia il terminale.

## **Utilizzo**
Una volta installata, puoi utilizzare la CLI eseguendo:
```
flutter_starter
```
La CLI ti guiderà attraverso il processo di creazione di un nuovo progetto Flutter:

1. **Nome del progetto**: Ti verrà chiesto di inserire il nome del progetto in formato snake_case.

2. **Descrizione del progetto**: Puoi fornire una descrizione per il tuo progetto (opzionale).

3. **Organizzazione del progetto**: Puoi specificare l’organizzazione (opzionale).

4. **Application ID**: Puoi specificare un Application ID personalizzato (opzionale).

5. **Aggiunta di Dipendenze**: Ti verrà chiesto se desideri aggiungere alcune dipendenze comuni:

•  go_router: Routing per applicazioni Flutter.

•  json_serializable: Supporto per la serializzazione JSON.

•  dio: Client HTTP per Dart.

La CLI creerà il progetto utilizzando very_good_cli, aggiungerà le dipendenze selezionate e eseguirà flutter pub get per scaricare le dipendenze.