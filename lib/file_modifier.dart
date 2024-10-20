import 'dart:io';

class FileModifier {
  /// Sostituisce una riga specifica in un file Dart.
  ///
  /// [filePath] è il percorso del file da modificare.
  /// [pattern] è la stringa o espressione regolare da cercare.
  /// [replacement] è la stringa che sostituirà la riga trovata.
  static Future<void> replaceLineInFile({
    required String filePath,
    required String pattern,
    required String replacement,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      print('Il file $filePath non esiste.');
      return;
    }

    // Leggi tutte le righe del file
    List<String> lines = await file.readAsLines();

    bool lineReplaced = false;

    // Itera su tutte le righe e sostituisci quella che corrisponde al pattern
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains(pattern)) {
        lines[i] = replacement;
        lineReplaced = true;
        print('Riga sostituita: ${lines[i]}');
        break; // Se desideri sostituire solo la prima occorrenza
      }
    }

    if (!lineReplaced) {
      print('Nessuna riga contenente "$pattern" è stata trovata in $filePath.');
      return;
    }

    // Scrivi le righe modificate nel file
    await file.writeAsString(lines.join('\n'));
    print('File $filePath aggiornato con successo.');
  }

  /// Sostituisce tutto il contenuto di un file con il testo passato
  static Future<void> replaceFileContent({
    required String filePath,
    required String newContent,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      print('Il file $filePath non esiste.');
      return;
    }

    try {
      // Sovrascrivi tutto il contenuto del file con il nuovo contenuto
      await file.writeAsString(newContent);
      print('Il contenuto del file $filePath è stato sostituito con successo.');
    } catch (e) {
      print('Errore durante la sostituzione del contenuto nel file: $e');
    }
  }
}
