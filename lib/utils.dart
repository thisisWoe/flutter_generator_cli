import 'dart:io';

import 'package:flutter_starter_cli/command_runner.dart';
import 'package:flutter_starter_cli/dependency_model.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';

class Utils {
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

  static bool isValidProjectName({required String? projectName}) {
    if (projectName == null || projectName.isEmpty) {
      print(
          'Il nome del progetto non è disponibile. Impossibile aggiungere dipendenze.');
      return false;
    }
    return true;
  }

  static bool projectExists({required Directory projectDirectory}) {
    if (!projectDirectory.existsSync()) {
      print(
          'La directory del progetto "$projectDirectory" non esiste. Impossibile aggiungere dipendenze.');
      return false;
    }
    return true;
  }

  static List<Dependency> getAvailableDependencies() {
    return [
      Dependency(name: 'go_router', description: 'Routing per app Flutter'),
      Dependency(
          name: 'json_serializable',
          description: 'Supporto per la serializzazione JSON'),
      Dependency(name: 'dio', description: 'Client HTTP per Dart'),
      Dependency(
          name: 'riverpod',
          description: 'Framework di caching reattivo e data-binding'),
    ];
  }

  static Future<List<Dependency>> promptUserForDependencies({
    required List<Dependency> dependencies,
  }) async {
    List<Dependency> selected = [];

    for (var package in dependencies) {
      stdout.write(
          'Vuoi aggiungere "${package.name}" (${package.description})? (y/N): ');
      String? response = stdin.readLineSync();

      if (response != null && response.toLowerCase() == 'y') {
        selected.add(package);
      }
    }

    return selected;
  }

  // static Future<void> addRequiredPathDependency({
  //   required CommandRunner commandRunner,
  // }) async {
  //   await addPackage(
  //     packageName: 'path',
  //     commandRunner: commandRunner,
  //   );
  // }

  static Future<void> addRiverpod({
    required CommandRunner commandRunner,
  }) async {
    await addPackage(
      packageName: 'riverpod',
      commandRunner: commandRunner,
    );
    await addPackage(
      packageName: 'hooks_riverpod',
      commandRunner: commandRunner,
    );
  }

  static Future<void> addJsonSerializable({
    required CommandRunner commandRunner,
  }) async {
    await addPackage(
        packageName: 'json_annotation',
        isDev: true,
        commandRunner: commandRunner);
    await addPackage(
      packageName: 'build_runner',
      isDev: true,
      commandRunner: commandRunner,
    );
    await addPackage(
        packageName: 'json_serializable',
        isDev: true,
        commandRunner: commandRunner);
  }

  static Future<void> addPackage({
    required CommandRunner commandRunner,
    required String packageName,
    bool isDev = false,
  }) async {
    final args = ['pub', 'add', packageName];
    if (isDev) args.add('--dev');

    final result = await commandRunner.run('dart', args);

    if (result.exitCode == 0) {
      print('\nPacchetto "$packageName" aggiunto con successo!\n');
    } else {
      print('\nErrore durante l\'aggiunta del pacchetto "$packageName".');
      print('Dettagli dell\'errore: ${result.stderr}');
      throw Exception(
          'Errore durante l\'aggiunta del pacchetto "$packageName".');
    }
  }

  static Future<void> runPubGet({required CommandRunner commandRunner}) async {
    final loadingIndicator =
        LoadingIndicator(label: 'Esecuzione di flutter pub get');
    loadingIndicator.start();

    try {
      var result = await commandRunner.run('flutter', ['pub', 'get']);

      if (result.exitCode == 0) {
        print('\nLe dipendenze sono state recuperate con successo!');
      } else {
        print('\nErrore durante il recupero delle dipendenze.');
        print('Dettagli dell\'errore: ${result.stderr}');
        throw Exception('Errore durante il recupero delle dipendenze.');
      }
    } finally {
      loadingIndicator.stop();
    }
  }
}
