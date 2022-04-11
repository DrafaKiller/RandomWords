import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SavedWords])
class Database extends _$Database {
  Database() : super(_openDatabase());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openDatabase() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    });
  }

  Future<List<SavedWord>> getSavedWordPairs() => select(savedWords).get();
  Stream<List<SavedWord>> watchSavedWords() => select(savedWords).watch();
  Future<int> addSavedWord(SavedWordsCompanion savedWord) => into(savedWords).insert(savedWord);
  Future<int> addSaveWordByName(String word) => addSavedWord(SavedWordsCompanion(word: Value(word)));
  Future removeSavedWord(SavedWord savedWord) => delete(savedWords).delete(savedWord);
  Future removeSavedWordByName(String word) => (delete(savedWords)..where((savedWord) => savedWord.word.equals(word))).go();
  Future removeAllSavedWords() => delete(savedWords).go();
}