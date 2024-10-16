import 'dart:io';

import 'package:flutter_starter_cli/cli.dart';
import 'package:flutter_starter_cli/command_runner.dart';

Future<void> main(List<String> arguments) async {
  var cli = CLI(commandRunner: RealCommandRunner());

  try {
    String dartPath = await cli.checkDartInstallation();
    String flutterPath = await cli.checkFlutterInstallation();
    await cli.runFlutterDoctor();
    await cli.checkVeryGoodCLI();
    String? projectName = await cli.createFlutterProject();
    await cli.addDependencies(projectName: projectName);
    print('Process completed!');
  } catch (e) {
    // print(e);
    exit(1);
  }
}
