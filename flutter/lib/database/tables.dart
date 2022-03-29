import 'package:drift/drift.dart';

class SavedWordPairs extends Table {
  TextColumn get first => text()();
  TextColumn get second => text()();

  @override
  Set<Column>? get primaryKey => { first, second };
}