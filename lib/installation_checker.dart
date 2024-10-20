import 'dart:io';

import 'package:flutter_starter_cli/command_runner.dart';
import 'package:flutter_starter_cli/loading_indicator.dart';

class InstallationChecker {
  final CommandRunner commandRunner;

  InstallationChecker({required this.commandRunner});

  Future<String> checkDartInstallation(
      // {required CommandRunner commandRunner,}
  ) async {
    await checkCommandInstallation(
      command: 'dart',
      arguments: ['--version'],
      installInstructions:
          'Follow the instructions at https://flutter.dev/docs/get-started/install',
      // commandRunner: commandRunner,
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

  Future<void> checkCommandInstallation({
    required String command,
    required List<String> arguments,
    required String installInstructions,
    // required CommandRunner commandRunner,
  }) async {
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
      command: 'flutter',
      arguments: ['--version'],
      installInstructions: 'Follow the instructions at https://flutter.dev/docs/get-started/install',
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

  Future<void> checkVeryGoodCLI() async {
    await checkCommandInstallation(
      command: 'very_good',
      arguments: ['--version'],
      installInstructions: 'dart pub global activate very_good_cli',
    );
  }
}
