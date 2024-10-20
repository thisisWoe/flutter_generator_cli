import 'package:flutter_starter_cli/command_executor.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';
import 'package:flutter_starter_cli/models/dependency_model.dart';

class DependencyManager {
  final CommandExecutor commandExecutor;

  DependencyManager({required this.commandExecutor});

  List<Dependency> getAvailableDependencies() {
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

  Future<void> addRiverpod({
    required CommandExecutor commandExecutor,
  }) async {
    await addPackage(
      packageName: 'riverpod',
      commandExecutor: commandExecutor,
    );
    await addPackage(
      packageName: 'hooks_riverpod',
      commandExecutor: commandExecutor,
    );
  }

  Future<void> addJsonSerializable({
    required CommandExecutor commandExecutor,
  }) async {
    await addPackage(
        packageName: 'json_annotation',
        isDev: true,
        commandExecutor: commandExecutor);
    await addPackage(
      packageName: 'build_runner',
      isDev: true,
      commandExecutor: commandExecutor,
    );
    await addPackage(
        packageName: 'json_serializable',
        isDev: true,
        commandExecutor: commandExecutor);
  }

  Future<void> addPackage({
    required CommandExecutor commandExecutor,
    required String packageName,
    bool isDev = false,
  }) async {
    final args = ['pub', 'add', packageName];
    if (isDev) args.add('--dev');

    final result = await commandExecutor.run('dart', args);

    if (result.exitCode == 0) {
      print('\nPacchetto "$packageName" aggiunto con successo!\n');
    } else {
      print('\nErrore durante l\'aggiunta del pacchetto "$packageName".');
      print('Dettagli dell\'errore: ${result.stderr}');
      throw Exception(
          'Errore durante l\'aggiunta del pacchetto "$packageName".');
    }
  }

  Future<void> runPubGet({required CommandExecutor commandExecutor}) async {
    final loadingIndicator =
        LoadingIndicator(label: 'Esecuzione di flutter pub get');
    loadingIndicator.start();

    try {
      var result = await commandExecutor.run('flutter', ['pub', 'get']);

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
