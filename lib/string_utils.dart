class StringUtils {
  static String toSnakeCase(String input) {
    // Verifica se la stringa è già in snake_case (nessuna lettera maiuscola)
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return input;
    }

    // Divide la stringa alle lettere maiuscole e inserisce un underscore prima di ciascuna
    final splitted = input.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match m) => '_${m.group(0)}',
    );

    // Converte tutto in minuscolo e rimuove eventuali underscore iniziali
    final snakeCase = splitted.toLowerCase().replaceFirst(RegExp(r'^_+'), '');

    return snakeCase;
  }

  static String capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String lowerFirstFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }
}
