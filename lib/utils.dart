import 'dart:io';

import 'package:flutter_starter_cli/command_executor.dart';
import 'package:flutter_starter_cli/models/dependency_model.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';

class Utils {
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
}
