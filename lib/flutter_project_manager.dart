import 'dart:io';

import 'package:flutter_starter_cli/command_executor.dart';
import 'package:flutter_starter_cli/dependency_manager.dart';
import 'package:flutter_starter_cli/file_manager.dart';
import 'package:flutter_starter_cli/models/dependency_model.dart';
import 'package:flutter_starter_cli/file_editor.dart';
import 'package:flutter_starter_cli/dependency_checker.dart';
import 'package:flutter_starter_cli/launcher.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';
import 'package:flutter_starter_cli/string_utils.dart';
import 'package:flutter_starter_cli/utils.dart';
import 'package:path/path.dart' as path;

class FlutterProjectManager {
  final CommandExecutor commandExecutor;
  late DependencyChecker installationChecker;
  late DependencyManager dependencyManager;
  FileManager fileManager = FileManager();
  String? projectTitle;

  FlutterProjectManager ({required this.commandExecutor}) {
    installationChecker = DependencyChecker(commandExecutor: commandExecutor);
    dependencyManager = DependencyManager(commandExecutor: commandExecutor);
  }

  Future<String> checkDartInstallation() async {
    return await installationChecker.checkDartInstallation();
  }

  Future<String> checkFlutterInstallation() async {
    return await installationChecker.checkFlutterInstallation();
  }

  Future<void> runFlutterDoctor() async {
    await installationChecker.runFlutterDoctor();
  }

  Future<void> checkVeryGoodCLI() async {
    await installationChecker.checkVeryGoodCLI();
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
      var result = await commandExecutor.run('very_good', arguments);

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

  Future<void> addDependencies({required String? projectName}) async {
    if (!Utils.isValidProjectName(projectName: projectName)) return;

    final projectDirectory = Directory(projectName!);

    if (!Utils.projectExists(projectDirectory: projectDirectory)) return;

    final originalDirectory = Directory.current;

    try {
      Directory.current = projectDirectory;
      print('Directory corrente cambiata a: ${Directory.current.path}\n');

      final dependencies = dependencyManager.getAvailableDependencies();

      final selectedDependencies = dependencies;
      // await Utils.promptUserForDependencies(dependencies: dependencies);

      if (selectedDependencies.isNotEmpty) {
        await _installDependencies(selectedDependencies);
        // await Utils.addRequiredPathDependency(commandExecutor: commandExecutor);
        await dependencyManager.runPubGet(commandExecutor: commandExecutor);
      }
    } finally {
      Directory.current = originalDirectory;
    }
  }

  Future<void> _installDependencies(List<Dependency> dependencies) async {
    for (var package in dependencies) {
      final loadingIndicator = LoadingIndicator(
          label:
              'Aggiunta del pacchetto${package.name == 'json_serializable' ? ' inerente a json_serializable:' : ': ${package.name}'}');
      loadingIndicator.start();

      try {
        if (package.name == 'riverpod') {
          await dependencyManager.addRiverpod(commandExecutor: commandExecutor);
        } else if (package.name == 'json_serializable') {
          await dependencyManager.addJsonSerializable(commandExecutor: commandExecutor);
        } else {
          await dependencyManager.addPackage(
            packageName: package.name,
            isDev: package.isDev,
            commandExecutor: commandExecutor,
          );
        }
      } catch (e) {
        print(
            '\nErrore durante l\'aggiunta del pacchetto "${package.name}": $e');
      } finally {
        loadingIndicator.stop();
      }
    }
  }

  Future<String> createMVVMArchitecture({required String projectName}) async {
    final loadingIndicator =
        LoadingIndicator(label: 'Creating MVVM Architecture...');
    loadingIndicator.start();

    String pathProviders = '$projectName/lib/di';
    await fileManager.createRepository(pathProviders);

    String pathModels = '$projectName/lib/models';
    await fileManager.createRepository(pathModels);

    String pathServices = '$projectName/lib/services';
    await fileManager.createRepository(pathServices);

    String pathViews = '$projectName/lib/views';
    await fileManager.createRepository(pathViews);

    String pathWidgets = '$projectName/lib/widgets';
    await fileManager.createRepository(pathWidgets);

    String pathViewModels = '$projectName/lib/view_models';
    await fileManager.createRepository(pathViewModels);
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
    final replacement = Launcher.bootstrap;

    // Usa il FileModifier per sostituire la riga nel file
    await FileEditor.replaceLineInFile(
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
    String? modelName,
  }) async {
    // controllo se è scritto in snake case
    final loadingIndicator =
        LoadingIndicator(label: 'Creating MVVM Component...');
    loadingIndicator.start();

    String snakeCase = '';
    if (nameComponent != null && nameComponent.isNotEmpty) {
      snakeCase = StringUtils.toSnakeCase(nameComponent);
    } else {
      throw Exception('The name of the component is required.');
    }
    String? pathModel = (modelName != null && modelName.isNotEmpty)
        ? '$pathLib/models/${StringUtils.toSnakeCase(modelName)}_model.dart'
        : null;
    String pathView = '$pathLib/views/${snakeCase}_view.dart';
    String pathViewModel = '$pathLib/view_models/${snakeCase}_view_model.dart';
    if (pathModel != null) {
      await fileManager.createDartFile(
          pathModel,
          _getContentDartModel(
            modelName: modelName!,
          ));
    }
    String providerName = await _createFileProviders(
      nameComponentCamelCase: nameComponent,
      pathLib: pathLib,
      isBuildingState: isBuildingState,
    );
    await fileManager.createDartFile(
        pathView,
        _getContentDartView(
          nameComponent: nameComponent,
          providerName: providerName,
          isBuildingState: isBuildingState,
        ));
    await fileManager.createDartFile(
        pathViewModel,
        _getContentDartViewModel(
          nameComponent: nameComponent,
          isBuildingState: isBuildingState,
        ));

    loadingIndicator.stop();
  }

  String _getContentDartModel({required String modelName}) {
    return Launcher.postModel(modelName: modelName);
  }

  String _getContentDartView({
    required String nameComponent,
    required String providerName,
    required bool isBuildingState,
  }) {
    if (isBuildingState) {
      return Launcher.componentViewFirstLaunch(projectName: projectTitle!);
    }
    return Launcher.componentView(
      projectName: projectTitle!,
      nameComponent: nameComponent,
      providerName: providerName,
    );
  }

  String _getContentDartViewModel({
    required String nameComponent,
    required bool isBuildingState,
  }) {
    if (isBuildingState) {
      return Launcher.componentViewModelFirstLaunch(projectName: projectTitle!);
    }
    return Launcher.componentViewModel(
      projectName: projectTitle!,
      nameComponent: nameComponent,
    );
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
      providerName = StringUtils.lowerFirstFirst(nameComponentCamelCase);
      // TODO: COMPLETARE
    }

    String pathProviders = '$pathLib/di/providers.dart';
    await fileManager.createDartFile(
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
    fileManager.createRepository(pathRouter);
    String pathRouterFile = '$pathRouter/routes.dart';
    fileManager.createDartFile(
        pathRouterFile, Launcher.router(projectName: projectTitle));
  }

  Future<void> createAppShell({
    required String projectName,
  }) async {
    String pathAppShell = '$projectName/lib/views/app_shell.dart';
    fileManager.createDartFile(
        pathAppShell, Launcher.appShell(projectName: projectTitle));
  }

  Future<void> createExamplePages({
    required String projectName,
  }) async {
    String pathExamplePages = '$projectName/lib/views/example_pages.dart';
    fileManager.createDartFile(
        pathExamplePages, Launcher.examplePages(projectName: projectTitle));
  }

  Future<void> createMain({
    required String projectName,
  }) async {
    String pathMain = '$projectName/lib/main.dart';
    fileManager.createDartFile(pathMain, Launcher.main(projectName: projectTitle));
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

      // Usa il FileEditor per editare il file
      await FileEditor.replaceFileContent(
        filePath: mainFilePath,
        newContent: Launcher.editMainFiles(projectName: projectName),
      );
    }
  }

  Future<void> createNavigationBar({required String projectName}) async {
    String pathNavigationBar = '$projectName/lib/widgets/navigation_bar.dart';
    fileManager.createDartFile(
        pathNavigationBar, Launcher.navigationBar(projectName: projectTitle));
  }
}
