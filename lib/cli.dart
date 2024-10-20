import 'dart:io';

import 'package:flutter_starter_cli/command_runner.dart';
import 'package:flutter_starter_cli/creator.dart';
import 'package:flutter_starter_cli/dependency_model.dart';
import 'package:flutter_starter_cli/file_modifier.dart';
import 'package:flutter_starter_cli/installation_checker.dart';
import 'package:flutter_starter_cli/launcher.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';
import 'package:flutter_starter_cli/utils.dart';
import 'package:path/path.dart' as path;

class CLI {
  final CommandRunner commandRunner;
  String? projectTitle;
  late InstallationChecker installationChecker;
  Creator creator = Creator();

  CLI({required this.commandRunner}) {
    installationChecker = InstallationChecker(commandRunner: commandRunner);
  }

  Future<String> checkDartInstallation() async {
    // await checkCommandInstallation(
    //   'dart',
    //   ['--version'],
    //   'Follow the instructions at https://flutter.dev/docs/get-started/install',
    // );
    // String? dartPath = await findCommandPath('dart');
    // if (dartPath != null) {
    //   print('Dart is installed at: $dartPath');
    //   return dartPath;
    // } else {
    //   print('Could not find the path to the Dart executable.');
    //   throw Exception('Could not find the path to the Dart executable.');
    // }
    return await installationChecker.checkDartInstallation();
  }

  // Future<String?> findCommandPath(String command) async {
  //   ProcessResult result;
  //   if (Platform.isWindows) {
  //     // Su Windows, utilizziamo il comando 'where'
  //     result = await Process.run('where', [command]);
  //   } else {
  //     // Su sistemi Unix-like, utilizziamo il comando 'which'
  //     result = await Process.run('which', [command]);
  //   }
  //
  //   if (result.exitCode == 0) {
  //     // Il comando è stato trovato, restituiamo il percorso
  //     return result.stdout.toString().trim();
  //   } else {
  //     // Comando non trovato
  //     return null;
  //   }
  // }

  Future<String> checkFlutterInstallation() async {
    // await checkCommandInstallation(
    //   'flutter',
    //   ['--version'],
    //   'Follow the instructions at https://flutter.dev/docs/get-started/install',
    // );
    // String? flutterPath = await findCommandPath('flutter');
    // if (flutterPath != null) {
    //   print('Flutter is installed at: $flutterPath');
    //   return flutterPath;
    // } else {
    //   print('Could not find the path to the Flutter executable.');
    //   throw Exception('Could not find the path to the Flutter executable.');
    // }
    return await installationChecker.checkFlutterInstallation();
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
    // await checkCommandInstallation(
    //   'very_good',
    //   ['--version'],
    //   'dart pub global activate very_good_cli',
    // );
    await installationChecker.checkVeryGoodCLI();
  }

  // Future<void> checkCommandInstallation(
  //   String command,
  //   List<String> arguments,
  //   String installInstructions,
  // ) async {
  //   final LoadingIndicator loadingIndicator =
  //       LoadingIndicator(label: 'Checking for $command');
  //   loadingIndicator.start();
  //   // await Future.delayed(Duration(seconds: 3));
  //   var result = await commandRunner.run(command, arguments);
  //   if (result.exitCode == 0) {
  //     print('\n$command is installed: ${result.stdout}');
  //   } else {
  //     print('Error: $command is not installed or not in PATH.');
  //     print('Error details: ${result.stderr}');
  //     print('You can install it by running:');
  //     print(installInstructions);
  //     // exit(1);
  //     throw Exception('$command is not installed');
  //   }
  //   loadingIndicator.stop();
  // }

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
        'If you want, enter a custom description for your project (optional, press [enter] to skip): ');
    String? projectDescription = stdin.readLineSync() ?? '';

    // Chiedi un org del progetto
    stdout.write(
        'If you want, enter a custom org for your project (optional, press [enter] to skip): ');
    String? projectOrg = stdin.readLineSync() ?? '';

    // Chiedi un org del progetto
    stdout.write(
        'If you want, enter a custom application id for your project (optional, press [enter] to skip): ');
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
        projectTitle = projectName;
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

  // Future<void> addDependencies({required String? projectName}) async {
  //   if (projectName == null || projectName.isEmpty) {
  //     print('Project name is not available. Cannot add dependencies.');
  //     return;
  //   }
  //
  //   // Cambia la directory corrente nella cartella del progetto
  //   var projectDirectory = Directory(projectName);
  //
  //   if (!projectDirectory.existsSync()) {
  //     print(
  //         'The project directory "$projectName" does not exist. Cannot add dependencies.');
  //     return;
  //   }
  //
  //   // Salva la directory corrente per ripristinarla in seguito
  //   var originalDirectory = Directory.current;
  //
  //   try {
  //     // Cambia la directory corrente alla cartella del progetto
  //     Directory.current = projectDirectory;
  //     print('Current directory changed to: ${Directory.current.path}');
  //
  //     print('\nDo you want to add additional dependencies to your project?');
  //
  //     // Lista dei pacchetti da offrire all'utente
  //     final packages = [
  //       {'name': 'go_router', 'description': 'Routing for Flutter apps'},
  //       {
  //         'name': 'json_serializable',
  //         'description': 'JSON serialization support'
  //       },
  //       {'name': 'dio', 'description': 'HTTP client for Dart'},
  //       {
  //         'name': 'riverpod',
  //         'description': 'A reactive caching and data-binding framework'
  //       },
  //     ];
  //
  //     bool dependenciesAdded = false;
  //
  //     for (var package in packages) {
  //       stdout.write(
  //           'Would you like to add "${package['name']}" (${package['description']})? (y/N): ');
  //       String? response = stdin.readLineSync();
  //
  //       if (response != null && response.toLowerCase() == 'y') {
  //         final loadingIndicator =
  //             LoadingIndicator(label: 'Adding package: ${package['name']}');
  //         loadingIndicator.start();
  //
  //         try {
  //           if (package['name'] == 'riverpod') {
  //             // Esegui il comando 'dart pub add package_name' nella directory del progetto
  //             var result = await commandRunner
  //                 .run('dart', ['pub', 'add', package['name']!]);
  //             if (result.exitCode == 0) {
  //               print(
  //                   '\nPackage "${package['name']}" has been added successfully!');
  //               dependenciesAdded = true;
  //             } else {
  //               print('\nError adding package "${package['name']}".');
  //               print('Details of the error: ${result.stderr}');
  //               throw Exception('Error adding package "${package['name']}".');
  //             }
  //             // Esegui il comando 'dart pub add package_name' nella directory del progetto
  //             var resultHooks = await commandRunner
  //                 .run('dart', ['pub', 'add', 'hooks_riverpod']);
  //             if (resultHooks.exitCode == 0) {
  //               print(
  //                   '\nPackage "hooks_riverpod" has been added successfully!');
  //               dependenciesAdded = true;
  //             } else {
  //               print('\nError adding package "hooks_riverpod".');
  //               print('Details of the error: ${resultHooks.stderr}');
  //               throw Exception('Error adding package "hooks_riverpod".');
  //             }
  //           } else if (package['name'] == 'json_serializable') {
  //             List<String> innerPackages = [
  //               'json_annotation',
  //               'build_runner',
  //               'json_serializable',
  //             ];
  //             for (var dependency in innerPackages) {
  //               var result = await commandRunner.run('dart', [
  //                 'pub',
  //                 'add',
  //                 dependency == 'json_annotation'
  //                     ? dependency
  //                     : '$dependency --dev'
  //               ]);
  //               if (result.exitCode == 0) {
  //                 print('\nPackage "$dependency" has been added successfully!');
  //                 dependenciesAdded = true;
  //               } else {
  //                 print('\nError adding package "$dependency".');
  //                 print('Details of the error: ${result.stderr}');
  //                 throw Exception('Error adding package "$dependency".');
  //               }
  //             }
  //           } else {
  //             // Esegui il comando 'dart pub add package_name' nella directory del progetto
  //             var result = await commandRunner
  //                 .run('dart', ['pub', 'add', package['name']!]);
  //             if (result.exitCode == 0) {
  //               print(
  //                   '\nPackage "${package['name']}" has been added successfully!');
  //               dependenciesAdded = true;
  //             } else {
  //               print('\nError adding package "${package['name']}".');
  //               print('Details of the error: ${result.stderr}');
  //               throw Exception('Error adding package "${package['name']}".');
  //             }
  //           }
  //         } finally {
  //           loadingIndicator.stop();
  //         }
  //       }
  //     }
  //
  //     // Se sono state aggiunte dipendenze, esegui 'flutter pub get'
  //     if (dependenciesAdded) {
  //       final loadingIndicator =
  //           LoadingIndicator(label: 'Running flutter pub get');
  //       loadingIndicator.start();
  //
  //       try {
  //         var result = await commandRunner.run('flutter', ['pub', 'get']);
  //
  //         if (result.exitCode == 0) {
  //           print('\nDependencies have been fetched successfully!');
  //         } else {
  //           print('\nError fetching dependencies.');
  //           print('Details of the error: ${result.stderr}');
  //           throw Exception('Error fetching dependencies.');
  //         }
  //       } finally {
  //         loadingIndicator.stop();
  //       }
  //     }
  //   } finally {
  //     // Ripristina la directory originale
  //     Directory.current = originalDirectory;
  //   }
  // }

  Future<void> addDependencies({required String? projectName}) async {
    if (!Utils.isValidProjectName(projectName: projectName)) return;

    final projectDirectory = Directory(projectName!);

    if (!Utils.projectExists(projectDirectory: projectDirectory)) return;

    final originalDirectory = Directory.current;

    try {
      Directory.current = projectDirectory;
      print('Directory corrente cambiata a: ${Directory.current.path}\n');

      final dependencies = Utils.getAvailableDependencies();

      final selectedDependencies = dependencies;
      // await Utils.promptUserForDependencies(dependencies: dependencies);

      if (selectedDependencies.isNotEmpty) {
        await _installDependencies(selectedDependencies);
        // await Utils.addRequiredPathDependency(commandRunner: commandRunner);
        await Utils.runPubGet(commandRunner: commandRunner);
      }
    } finally {
      Directory.current = originalDirectory;
    }
  }

  Future<void> _installDependencies(List<Dependency> dependencies) async {
    // bool dependenciesAdded = false;

    for (var package in dependencies) {
      final loadingIndicator = LoadingIndicator(
          label:
              'Aggiunta del pacchetto${package.name == 'json_serializable' ? ' inerente a json_serializable:' : ': ${package.name}'}');
      loadingIndicator.start();

      try {
        if (package.name == 'riverpod') {
          await Utils.addRiverpod(commandRunner: commandRunner);
        } else if (package.name == 'json_serializable') {
          await Utils.addJsonSerializable(commandRunner: commandRunner);
        } else {
          await Utils.addPackage(
            packageName: package.name,
            isDev: package.isDev,
            commandRunner: commandRunner,
          );
        }
        // dependenciesAdded = true;
      } catch (e) {
        print(
            '\nErrore durante l\'aggiunta del pacchetto "${package.name}": $e');
      } finally {
        loadingIndicator.stop();
      }
    }

    // if (dependenciesAdded == dependencies.length) {
    //   await Utils.runPubGet(commandRunner: commandRunner);
    // }
  }

  Future<String> createMVVMArchitecture({required String projectName}) async {
    final loadingIndicator =
        LoadingIndicator(label: 'Creating MVVM Architecture...');
    loadingIndicator.start();

    String pathProviders = '$projectName/lib/di';
    await creator.createRepository(pathProviders);

    String pathModels = '$projectName/lib/models';
    await creator.createRepository(pathModels);

    String pathServices = '$projectName/lib/services';
    await creator.createRepository(pathServices);

    String pathViews = '$projectName/lib/views';
    await creator.createRepository(pathViews);

    String pathWidgets = '$projectName/lib/widgets';
    await creator.createRepository(pathWidgets);

    String pathViewModels = '$projectName/lib/view_models';
    await creator.createRepository(pathViewModels);
    loadingIndicator.stop();

    return '$projectName/lib';
  }

  /// Metodo che modifica la riga desiderata in progetto/lib/bootstrap.dart
  Future<void> modifyBootstrapFile({required String projectName}) async {
    // Verifica se il nome del progetto è valido
    if (projectName.isEmpty) {
      print('Il nome del progetto non è valido.');
      return;
    }

    // Costruisci il percorso del file da modificare
    final bootstrapFilePath = path.join(projectName, 'lib', 'bootstrap.dart');

    // Controlla se il file esiste
    if (!File(bootstrapFilePath).existsSync()) {
      print('Il file $bootstrapFilePath non esiste.');
      return;
    }

    // Definisci il pattern da cercare e la stringa di sostituzione
    final pattern = 'runApp(await builder());'; // La riga da sostituire
    final replacement = '''
  runApp(ProviderScope(child: builder() as Widget));
'''; // La nuova riga di sostituzione

    // Usa il FileModifier per sostituire la riga nel file
    await FileModifier.replaceLineInFile(
      filePath: bootstrapFilePath,
      pattern: pattern,
      replacement: replacement,
    );

    await _addProviderScopeImport(filePath: bootstrapFilePath);
  }

  /// Aggiunge l'import di hooks_riverpod nel file, se non già presente
  Future<void> _addProviderScopeImport({required String filePath}) async {
    final file = File(filePath);

    if (!await file.exists()) {
      print('Il file $filePath non esiste. Impossibile aggiungere l\'import.');
      return;
    }

    // Leggi tutte le righe del file
    List<String> lines = await file.readAsLines();
    final importLine = "import 'package:hooks_riverpod/hooks_riverpod.dart';";

    // Verifica se l'import è già presente
    if (lines.any((line) => line.contains(importLine))) {
      print('Import di hooks_riverpod già presente in $filePath.');
      return;
    }

    // Trova la posizione dell'ultimo import per inserire il nuovo import dopo di esso
    int lastImportIndex =
        lines.lastIndexWhere((line) => line.startsWith('import '));

    if (lastImportIndex != -1) {
      lines.insert(lastImportIndex + 1, importLine);
    } else {
      // Se non ci sono import, aggiungi l'import in cima al file
      lines.insert(0, importLine);
    }

    // Scrivi le modifiche nel file
    await file.writeAsString(lines.join('\n'));
    print('Import di hooks_riverpod aggiunto a $filePath.');
  }

  Future<void> createComponentMVVM({
    required String pathLib,
    required bool isBuildingState,
    String? nameComponent,
    String? nameModel,
  }) async {
    // controllo se è scritto in snake case
    final loadingIndicator =
        LoadingIndicator(label: 'Creating MVVM Component...');
    loadingIndicator.start();

    String snakeCase = '';
    if (nameComponent != null && nameComponent.isNotEmpty) {
      snakeCase = Utils.toSnakeCase(nameComponent);
    } else {
      throw Exception('The name of the component is required.');
    }
    String? pathModel = (nameModel != null && nameModel.isNotEmpty)
        ? '$pathLib/models/${Utils.toSnakeCase(nameModel)}_model.dart'
        : null;
    String pathView = '$pathLib/views/${snakeCase}_view.dart';
    String pathViewModel = '$pathLib/view_models/${snakeCase}_view_model.dart';
    if (pathModel != null) {
      await creator.createDartFile(
          pathModel,
          _getContentDartModel(
            nameComponent: nameComponent,
            isBuildingState: isBuildingState,
          ));
    }
    String providerName = await _createFileProviders(
      nameComponentCamelCase: nameComponent,
      pathLib: pathLib,
      isBuildingState: isBuildingState,
    );
    await creator.createDartFile(
        pathView,
        _getContentDartView(
          nameComponent: nameComponent,
          providerName: providerName,
          isBuildingState: isBuildingState,
        ));
    await creator.createDartFile(
        pathViewModel,
        _getContentDartViewModel(
          nameComponent: nameComponent,
          isBuildingState: isBuildingState,
        ));

    loadingIndicator.stop();
  }

  // Future<void> _createRepository(String path) async {
  //   // Ex: lib/utils
  //   final directory = Directory(path);
  //
  //   if (await directory.exists()) {
  //     print('The folder "${directory.path}" already exists.');
  //   } else {
  //     try {
  //       await directory.create(recursive: true);
  //       print('The folder has been created: ${directory.path}');
  //     } catch (e) {
  //       print('Error during the creation of the folder: $e');
  //     }
  //   }
  // }

  // Future<void> creator.createDartFile(String filePath, String content) async {
  //   // Ex: lib/utils/helper.dart
  //   final file = File(filePath);
  //
  //   if (await file.exists()) {
  //     print('The file "${file.path}" already exists.');
  //   } else {
  //     try {
  //       await file.create(recursive: true);
  //       await file.writeAsString(content);
  //       print('The file has been created: ${file.path}');
  //     } catch (e) {
  //       print('Error during the creation of the file: $e');
  //     }
  //   }
  // }

  String _getContentDartModel({
    required String nameComponent,
    required bool isBuildingState,
  }) {
    if (isBuildingState) {
      return Launcher.postModel(projectName: projectTitle);
    }
    return '''\
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ${Utils.capitalizeFirst(nameComponent)}Model {
  final int id;

  const ${Utils.capitalizeFirst(nameComponent)}Model({
    required this.id,
  });
}
    ''';
  }

  String _getContentDartView({
    required String nameComponent,
    required String providerName,
    required bool isBuildingState,
  }) {
    if (isBuildingState) {
      return Launcher.homeView(projectName: projectTitle);
    }
    return '''\
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prova/di/providers.dart';

class ${Utils.capitalizeFirst(nameComponent)}View extends ConsumerStatefulWidget {
  const ${Utils.capitalizeFirst(nameComponent)}View({super.key});

  @override
  ConsumerState<${Utils.capitalizeFirst(nameComponent)}View> createState() => _${Utils.capitalizeFirst(nameComponent)}ViewState();
}

class _${Utils.capitalizeFirst(nameComponent)}ViewState extends ConsumerState<${Utils.capitalizeFirst(nameComponent)}View> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final $providerName}ViewModel = ref.watch($providerName}ViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${Utils.capitalizeFirst(nameComponent)} View'),
      ),
    );
  }
}
    ''';
  }

  String _getContentDartViewModel({
    required String nameComponent,
    required bool isBuildingState,
  }) {
    if (isBuildingState) {
      return Launcher.homeViewModel(projectName: projectTitle);
    }
    return '''
    import 'package:flutter/material.dart';

class ${Utils.capitalizeFirst(nameComponent)}ViewModel extends ChangeNotifier {

}
    ''';
  }

  Future<String> _createFileProviders({
    required String pathLib,
    required String nameComponentCamelCase,
    required bool isBuildingState,
  }) async {
    String content = '';
    String providerName = '';
    if (isBuildingState) {
      providerName = 'homeViewModelProvider';
      content = Launcher.provider(projectName: projectTitle);
    } else {
      providerName = Utils.lowerFirstFirst(nameComponentCamelCase);
      // TODO: COMPLETARE
    }

    String pathProviders = '$pathLib/di/providers.dart';
    await creator.createDartFile(
      pathProviders,
      content,
    );
    return providerName;
  }

  Future<void> initializeApp({required String projectName}) async {
    await creteRouteConfig(
      projectName: projectName,
    );

    await createAppShell(
      projectName: projectName,
    );

    await createExamplePages(
      projectName: projectName,
    );

    await createMain(
      projectName: projectName,
    );

    await createNavigationBar(
      projectName: projectName,
    );

    String pathFirstDirectoryToDelete = '$projectName/lib/app';
    String pathSecondDirectoryToDelete = '$projectName/lib/counter';
    String pathThirdDirectoryToDelete = '$projectName/test/app';
    String pathFourthDirectoryToDelete = '$projectName/test/counter';
    await deleteDirectory(path: pathFirstDirectoryToDelete);
    await deleteDirectory(path: pathSecondDirectoryToDelete);
    await deleteDirectory(path: pathThirdDirectoryToDelete);
    await deleteDirectory(path: pathFourthDirectoryToDelete);

    await modifyBootstrapFile(projectName: projectTitle!);
    await modifyMainFile(projectName: projectName);
  }

  Future<void> creteRouteConfig({
    required String projectName,
  }) async {
    String pathRouter = '$projectName/lib/router';
    creator.createRepository(pathRouter);
    String pathRouterFile = '$pathRouter/routes.dart';
    creator.createDartFile(
        pathRouterFile, Launcher.router(projectName: projectTitle));
  }

  Future<void> createAppShell({
    required String projectName,
  }) async {
    String pathAppShell = '$projectName/lib/views/app_shell.dart';
    creator.createDartFile(
        pathAppShell, Launcher.appShell(projectName: projectTitle));
  }

  Future<void> createExamplePages({
    required String projectName,
  }) async {
    String pathExamplePages = '$projectName/lib/views/example_pages.dart';
    creator.createDartFile(
        pathExamplePages, Launcher.examplePages(projectName: projectTitle));
  }

  Future<void> createMain({
    required String projectName,
  }) async {
    String pathMain = '$projectName/lib/main.dart';
    creator.createDartFile(pathMain, Launcher.main(projectName: projectTitle));
  }

  /// Metodo per eliminare una directory e tutto il suo contenuto
  Future<void> deleteDirectory({required String path}) async {
    final directory = Directory(path);

    if (await directory.exists()) {
      try {
        await directory.delete(recursive: true);
        print('Directory $path eliminata con successo.');
      } catch (e) {
        print('Errore durante l\'eliminazione della directory $path: $e');
      }
    } else {
      print('La directory $path non esiste.');
    }
  }

  /// Metodo che modifica la riga desiderata in progetto/lib/bootstrap.dart
  Future<void> modifyMainFile({required String projectName}) async {
    List<String> mainFiles = [
      'main_development.dart',
      'main_staging.dart',
      'main_production.dart',
    ];

    // Verifica se il nome del progetto è valido
    if (projectName.isEmpty) {
      print('Il nome del progetto non è valido.');
      return;
    }

    for (String fileName in mainFiles) {
      // Costruisci il percorso del file da modificare
      final mainFilePath = path.join(projectName, 'lib', fileName);
      // Controlla se il file esiste
      if (!File(mainFilePath).existsSync()) {
        print('Il file $mainFilePath non esiste.');
        return;
      }

      // Usa il FileModifier per editare il file
      await FileModifier.replaceFileContent(
        filePath: mainFilePath,
        newContent: Launcher.editMainFiles(projectName: projectName),
      );
    }
  }

  Future<void> createNavigationBar({required String projectName}) async {
    String pathNavigationBar = '$projectName/lib/widgets/navigation_bar.dart';
    creator.createDartFile(
        pathNavigationBar, Launcher.navigationBar(projectName: projectTitle));
  }
}
