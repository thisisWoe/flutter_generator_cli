import 'dart:io';

class Creator {
  Future<void> createRepository(String path) async {
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

  Future<void> createDartFile(String filePath, String content) async {
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
