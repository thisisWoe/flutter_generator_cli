import 'dart:async';
import 'dart:io';
import 'package:process_run/process_run.dart';

abstract class CommandExecutor {
  Future<ProcessResult> run(String command, List<String> arguments);
}

class RealCommandExecutor implements CommandExecutor {
  @override
  Future<ProcessResult> run(String command, List<String> arguments) {
    print('Esecuzione del comando: $command ${arguments.join(' ')}');
    return runExecutableArguments(command, arguments, verbose: false);
  }


}
