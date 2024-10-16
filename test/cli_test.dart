import 'dart:io';

import 'package:flutter_starter_cli/cli.dart';
import 'package:flutter_starter_cli/command_runner.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockCommandRunner extends Mock implements CommandRunner {}

void main() {
  late MockCommandRunner mockCommandRunner;
  late CLI cli;

  setUp(() {
    mockCommandRunner = MockCommandRunner();
    cli = CLI(commandRunner: mockCommandRunner);
  });

  group('checkFlutterInstallation', () {
    test('successo quando Flutter è installato', () async {
      when(() => mockCommandRunner.run('flutter', ['--version'])).thenAnswer(
        (_) async => ProcessResult(0, 0, 'Flutter 3.24.3', ''),
      );

      await cli.checkFlutterInstallation();

      verify(() => mockCommandRunner.run('flutter', ['--version'])).called(1);
    });

    test('fallisce quando Flutter non è installato', () async {
      when(() => mockCommandRunner.run('flutter', ['--version'])).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'Command not found'),
      );

      expect(() => cli.checkFlutterInstallation(), throwsA(isA<Exception>()));
    });
  });

  group('runFlutterDoctor', () {
    test('successo quando non ci sono problemi', () async {
      when(() => mockCommandRunner.run('flutter', ['doctor'])).thenAnswer(
        (_) async =>
            ProcessResult(0, 0, 'Doctor summary:\nNo issues found!', ''),
      );

      await cli.runFlutterDoctor();

      verify(() => mockCommandRunner.run('flutter', ['doctor'])).called(1);
    });

    test('fallisce quando ci sono problemi', () async {
      when(() => mockCommandRunner.run('flutter', ['doctor'])).thenAnswer(
        (_) async =>
            ProcessResult(0, 1, 'Doctor summary:\n[!] Some issues found!', ''),
      );

      expect(() => cli.runFlutterDoctor(), throwsA(isA<Exception>()));
    });
  });

  group('checkVeryGoodCLI', () {
    test('successo quando Very Good CLI è installato', () async {
      when(() => mockCommandRunner.run('very_good', ['--version'])).thenAnswer(
        (_) async => ProcessResult(0, 0, 'Very Good CLI version 0.1.0', ''),
      );

      await cli.checkVeryGoodCLI();

      verify(() => mockCommandRunner.run('very_good', ['--version'])).called(1);
    });

    test('fallisce quando Very Good CLI non è installato', () async {
      when(() => mockCommandRunner.run('very_good', ['--version'])).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'Command not found'),
      );

      expect(() => cli.checkVeryGoodCLI(), throwsA(isA<Exception>()));
    });
  });
}
