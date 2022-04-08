// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class SavedWord extends DataClass implements Insertable<SavedWord> {
  final int id;
  final String word;
  SavedWord({required this.id, required this.word});
  factory SavedWord.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SavedWord(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      word: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}word'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    return map;
  }

  SavedWordsCompanion toCompanion(bool nullToAbsent) {
    return SavedWordsCompanion(
      id: Value(id),
      word: Value(word),
    );
  }

  factory SavedWord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedWord(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
    };
  }

  SavedWord copyWith({int? id, String? word}) => SavedWord(
        id: id ?? this.id,
        word: word ?? this.word,
      );
  @override
  String toString() {
    return (StringBuffer('SavedWord(')
          ..write('id: $id, ')
          ..write('word: $word')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, word);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedWord && other.id == this.id && other.word == this.word);
}

class SavedWordsCompanion extends UpdateCompanion<SavedWord> {
  final Value<int> id;
  final Value<String> word;
  const SavedWordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
  });
  SavedWordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
  }) : word = Value(word);
  static Insertable<SavedWord> custom({
    Expression<int>? id,
    Expression<String>? word,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
    });
  }

  SavedWordsCompanion copyWith({Value<int>? id, Value<String>? word}) {
    return SavedWordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedWordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word')
          ..write(')'))
        .toString();
  }
}

class $SavedWordsTable extends SavedWords
    with TableInfo<$SavedWordsTable, SavedWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedWordsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String?> word = GeneratedColumn<String?>(
      'word', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, word];
  @override
  String get aliasedName => _alias ?? 'saved_words';
  @override
  String get actualTableName => 'saved_words';
  @override
  VerificationContext validateIntegrity(Insertable<SavedWord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    return SavedWord.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SavedWordsTable createAlias(String alias) {
    return $SavedWordsTable(attachedDatabase, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $SavedWordsTable savedWords = $SavedWordsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedWords];
}
