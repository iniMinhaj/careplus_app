// core/storage/local_json_store.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Seed-then-persist storage for the mock backend's JSON fixtures.
///
/// Bundled `assets/mock/*.json` files are compiled into the app package and
/// are read-only at runtime. To make writes (new registrations, new
/// bookings) actually stick — including across app restarts — each fixture
/// is copied to the app's writable documents directory the first time it's
/// read, and all reads/writes after that go through the writable copy.
abstract interface class LocalJsonStore {
  Future<Map<String, dynamic>> read(String fileName);
  Future<void> write(String fileName, Map<String, dynamic> data);
}

class FileLocalJsonStore implements LocalJsonStore {
  Future<File> _fileFor(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/mock/$fileName');
  }

  @override
  Future<Map<String, dynamic>> read(String fileName) async {
    final file = await _fileFor(fileName);
    if (!await file.exists()) {
      final seed = await rootBundle.loadString('assets/mock/$fileName');
      await file.create(recursive: true);
      await file.writeAsString(seed);
      return jsonDecode(seed) as Map<String, dynamic>;
    }
    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  }

  @override
  Future<void> write(String fileName, Map<String, dynamic> data) async {
    final file = await _fileFor(fileName);
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }
}
