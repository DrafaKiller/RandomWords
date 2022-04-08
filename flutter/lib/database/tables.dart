import 'package:drift/drift.dart';

class SavedWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
}