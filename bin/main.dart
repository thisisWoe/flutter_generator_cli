import 'dart:io';

import 'package:flutter_starter_cli/flutter_project_manager.dart';
import 'package:flutter_starter_cli/command_executor.dart';

Future<void> main(List<String> arguments) async {
  var cli = FlutterProjectManager(commandExecutor: RealCommandExecutor());

  try {
    String dartPath = await cli.checkDartInstallation();
    String flutterPath = await cli.checkFlutterInstallation();
    await cli.runFlutterDoctor();
    await cli.checkVeryGoodCLI();
    String? projectName = await cli.createFlutterProject();
    await cli.addDependencies(
      projectName: projectName,
    );
    String path = await cli.createMVVMArchitecture(
      projectName: projectName!,
    );
    await cli.createComponentMVVM(
      pathLib: path,
      nameComponent: 'home',
      modelName: 'post',
      isBuildingState: true,
    );
    await cli.initializeApp(projectName: projectName);
    // await cli.modifyBootstrapFile(projectName: projectName);
    print('Process completed!');
  } catch (e) {
    // print(e);
    exit(1);
  }
}
