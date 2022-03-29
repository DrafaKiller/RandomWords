import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:english_words/english_words.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SavedWordPairs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openDatabase() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    });
  }
  
  // Future<List<WordPair>> getSavedWordPairs() => select(savedWordPairs).map((savedWord) => WordPair(savedWord.first, savedWord.second)).get();
  // Future saveWordPair(SavedWordPair savedWordPair) => into(savedWordPairs).insert(savedWordPair);
  // Future unsaveWordPair(SavedWordPair savedWordPair) => delete(savedWordPairs).delete(savedWordPair);
  
  Future<List<WordPair>> getSavedWordPairs() => select(savedWordPairs).map((savedWord) => WordPair(savedWord.first, savedWord.second)).get();
  Stream<List<WordPair>> watchSavedWordPairs() => select(savedWordPairs).map((savedWord) => WordPair(savedWord.first, savedWord.second)).watch();
  Future saveWordPair(WordPair wordPair) => into(savedWordPairs).insert(SavedWordPair(first: wordPair.first, second: wordPair.second));
  Future unsaveWordPair(WordPair wordPair) => delete(savedWordPairs).delete(SavedWordPair(first: wordPair.first, second: wordPair.second));
}