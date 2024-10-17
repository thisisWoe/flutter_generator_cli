import 'dart:io';

import 'package:flutter_starter_cli/command_runner.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';

class CLI {
  final CommandRunner commandRunner;

  CLI({required this.commandRunner});

  Future<String> checkDartInstallation() async {
    await checkCommandInstallation(
      'dart',
      ['--version'],
      'Follow the instructions at https://flutter.dev/docs/get-started/install',
    );
    String? dartPath = await findCommandPath('dart');
    if (dartPath != null) {
      print('Dart is installed at: $dartPath');
      return dartPath;
    } else {
      print('Could not find the path to the Dart executable.');
      throw Exception('Could not find the path to the Dart executable.');
    }
  }

  Future<String?> findCommandPath(String command) async {
    ProcessResult result;
    if (Platform.isWindows) {
      // Su Windows, utilizziamo il comando 'where'
      result = await Process.run('where', [command]);
    } else {
      // Su sistemi Unix-like, utilizziamo il comando 'which'
      result = await Process.run('which', [command]);
    }

    if (result.exitCode == 0) {
      // Il comando è stato trovato, restituiamo il percorso
      return result.stdout.toString().trim();
    } else {
      // Comando non trovato
      return null;
    }
  }

  Future<String> checkFlutterInstallation() async {
    await checkCommandInstallation(
      'flutter',
      ['--version'],
      'Follow the instructions at https://flutter.dev/docs/get-started/install',
    );
    String? flutterPath = await findCommandPath('flutter');
    if (flutterPath != null) {
      print('Flutter is installed at: $flutterPath');
      return flutterPath;
    } else {
      print('Could not find the path to the Flutter executable.');
      throw Exception('Could not find the path to the Flutter executable.');
    }
  }

  Future<void> runFlutterDoctor() async {
    // print('Running flutter doctor...');
    final LoadingIndicator loadingIndicator =
        LoadingIndicator(label: 'Running flutter doctor...');
    loadingIndicator.start();
    var doctorResult = await commandRunner.run('flutter', ['doctor']);
    print('\n${doctorResult.stdout}');

    var successMessages = [
      'No issues found!', // English
      'Nessun problema riscontrato!', // Italian
      // Add other languages if necessary
    ];

    if (doctorResult.exitCode == 0 &&
        successMessages.any((msg) => doctorResult.stdout.contains(msg))) {
      print('All necessary tools are installed.');
    } else {
      print('Some issues were found. Please resolve them before proceeding:');
      print(doctorResult.stdout);
      // exit(1);
      throw Exception('Issues detected by flutter doctor');
    }
    loadingIndicator.stop();
  }

  Future<void> checkVeryGoodCLI() async {
    await checkCommandInstallation(
      'very_good',
      ['--version'],
      'dart pub global activate very_good_cli',
    );
  }

  Future<void> checkCommandInstallation(
    String command,
    List<String> arguments,
    String installInstructions,
  ) async {
    final LoadingIndicator loadingIndicator =
        LoadingIndicator(label: 'Checking for $command');
    loadingIndicator.start();
    // await Future.delayed(Duration(seconds: 3));
    var result = await commandRunner.run(command, arguments);
    if (result.exitCode == 0) {
      print('\n$command is installed: ${result.stdout}');
    } else {
      print('Error: $command is not installed or not in PATH.');
      print('Error details: ${result.stderr}');
      print('You can install it by running:');
      print(installInstructions);
      // exit(1);
      throw Exception('$command is not installed');
    }
    loadingIndicator.stop();
  }

  Future<String?> createFlutterProject() async {
    print('Starting the creation of a Flutter project with very_good_cli.');

    String? projectName;

    // Ciclo per richiedere un nome di progetto valido
    while (true) {
      stdout.write('Please enter the name of the project (use snake_case): ');
      projectName = stdin.readLineSync();

      if (projectName == null || projectName.isEmpty) {
        stdout.write(
            'Project name cannot be empty. Do you want to cancel the process? (y/N): ');
        String? response = stdin.readLineSync();

        if (response != null && response.toLowerCase() == 'y') {
          print('Process cancelled.');
          throw Exception('Operation cancelled.');
        } else {
          // Continua il ciclo per richiedere nuovamente il nome del progetto
          continue;
        }
      }

      // Validazione del nome del progetto
      bool isValidName = RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName);

      if (!isValidName) {
        print('"$projectName" is not a valid name.');
        print(
            'The project name must start with a lowercase letter and can contain only lowercase letters, numbers, and underscores.');
        // Chiede nuovamente il nome del progetto
      } else {
        // Nome valido, esce dal ciclo
        break;
      }
    }

    // Controllo se la cartella esiste già
    var projectDir = Directory(projectName);

    if (projectDir.existsSync()) {
      stdout.write(
          'A folder named "$projectName" already exists. Do you want to overwrite it? (y/N): ');
      String? response = stdin.readLineSync();

      if (response == null || response.toLowerCase() != 'y') {
        print('Process cancelled.');
        throw Exception('Operation cancelled.');
      }
    }

    // Chiedi una descrizione del progetto
    stdout.write(
        'If you want, enter a custom description for your project (optional): ');
    String? projectDescription = stdin.readLineSync() ?? '';

    // Chiedi un org del progetto
    stdout
        .write('If you want, enter a custom org for your project (optional): ');
    String? projectOrg = stdin.readLineSync() ?? '';

    // Chiedi un org del progetto
    stdout.write(
        'If you want, enter a custom application id for your project (optional): ');
    String? projectAppId = stdin.readLineSync() ?? '';

    final LoadingIndicator loadingIndicator = LoadingIndicator(
        label: 'Creating project: $projectName with very_good_cli.');
    loadingIndicator.start();

    try {
      // Costruisci i parametri per il comando
      List<String> arguments = [
        'create',
        'flutter_app',
        projectName,
      ];

      if (projectDescription.isNotEmpty) {
        arguments.addAll(['--desc', projectDescription]);
      }

      if (projectOrg.isNotEmpty) {
        arguments.addAll(['--org', projectOrg]);
      }

      if (projectAppId.isNotEmpty) {
        arguments.addAll(['--application-id', projectAppId]);
      }

      // Esegui il comando
      var result = await commandRunner.run('very_good', arguments);

      if (result.exitCode == 0) {
        print('\nThe project "$projectName" has been successfully created!');
        return projectName;
      } else {
        print('\nError during the creation of the project.');
        print('Details of the error: ${result.stderr}');
        print('Process cancelled.');
        throw Exception('Error during the creation of the project.');
      }
    } finally {
      loadingIndicator.stop();
    }
  }

  Future<void> addDependencies({required String? projectName}) async {
    if (projectName == null || projectName.isEmpty) {
      print('Project name is not available. Cannot add dependencies.');
      return;
    }

    // Cambia la directory corrente nella cartella del progetto
    var projectDirectory = Directory(projectName);

    if (!projectDirectory.existsSync()) {
      print(
          'The project directory "$projectName" does not exist. Cannot add dependencies.');
      return;
    }

    // Salva la directory corrente per ripristinarla in seguito
    var originalDirectory = Directory.current;

    try {
      // Cambia la directory corrente alla cartella del progetto
      Directory.current = projectDirectory;
      print('Current directory changed to: ${Directory.current.path}');

      print('\nDo you want to add additional dependencies to your project?');

      // Lista dei pacchetti da offrire all'utente
      final packages = [
        {'name': 'go_router', 'description': 'Routing for Flutter apps'},
        {
          'name': 'json_serializable',
          'description': 'JSON serialization support'
        },
        {'name': 'dio', 'description': 'HTTP client for Dart'},
      ];

      bool dependenciesAdded = false;

      for (var package in packages) {
        stdout.write(
            'Would you like to add "${package['name']}" (${package['description']})? (y/N): ');
        String? response = stdin.readLineSync();

        if (response != null && response.toLowerCase() == 'y') {
          final loadingIndicator =
              LoadingIndicator(label: 'Adding package: ${package['name']}');
          loadingIndicator.start();

          try {
            // Esegui il comando 'dart pub add package_name' nella directory del progetto
            var result = await commandRunner
                .run('dart', ['pub', 'add', package['name']!]);

            if (result.exitCode == 0) {
              print(
                  '\nPackage "${package['name']}" has been added successfully!');
              dependenciesAdded = true;
            } else {
              print('\nError adding package "${package['name']}".');
              print('Details of the error: ${result.stderr}');
              throw Exception('Error adding package "${package['name']}".');
            }
          } finally {
            loadingIndicator.stop();
          }
        }
      }

      // Se sono state aggiunte dipendenze, esegui 'flutter pub get'
      if (dependenciesAdded) {
        final loadingIndicator =
            LoadingIndicator(label: 'Running flutter pub get');
        loadingIndicator.start();

        try {
          var result = await commandRunner.run('flutter', ['pub', 'get']);

          if (result.exitCode == 0) {
            print('\nDependencies have been fetched successfully!');
          } else {
            print('\nError fetching dependencies.');
            print('Details of the error: ${result.stderr}');
            throw Exception('Error fetching dependencies.');
          }
        } finally {
          loadingIndicator.stop();
        }
      }
    } finally {
      // Ripristina la directory originale
      Directory.current = originalDirectory;
    }
  }

  Future<void> createComponentMVVM(String? nameComponent) async {
    // controllo se è scritto in snake case

    if (nameComponent != null && nameComponent.isNotEmpty) {
      String snakeCase = toSnakeCase(nameComponent);
    } else {
      throw Exception('The name of the component is required.');
    }
  }

  String toSnakeCase(String input) {
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

  Future<void> _createRepository(String path) async {
    // Ex: lib/utils
    final directory = Directory(path);

    if (await directory.exists()) {
      print('The folder "${directory.path}" already exists.');
    } else {
      try {
        await directory.create(recursive: true);
        print('The folder has been created: ${directory.path}');
      } catch (e) {
        print('Error during the creation of the folder: $e');
      }
    }
  }

  Future<void> _createDartFile(String filePath, String content) async {
    // Ex: lib/utils/helper.dart
    final file = File(filePath);

    if (await file.exists()) {
      print('The file "${file.path}" already exists.');
    } else {
      try {
        await file.create(recursive: true);
        await file.writeAsString(content);
        print('The file has been created: ${file.path}');
      } catch (e) {
        print('Error during the creation of the file: $e');
      }
    }
  }
}
