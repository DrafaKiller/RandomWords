// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class SavedWordPair extends DataClass implements Insertable<SavedWordPair> {
  final String first;
  final String second;
  SavedWordPair({required this.first, required this.second});
  factory SavedWordPair.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SavedWordPair(
      first: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}first'])!,
      second: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}second'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['first'] = Variable<String>(first);
    map['second'] = Variable<String>(second);
    return map;
  }

  SavedWordPairsCompanion toCompanion(bool nullToAbsent) {
    return SavedWordPairsCompanion(
      first: Value(first),
      second: Value(second),
    );
  }

  factory SavedWordPair.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedWordPair(
      first: serializer.fromJson<String>(json['first']),
      second: serializer.fromJson<String>(json['second']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'first': serializer.toJson<String>(first),
      'second': serializer.toJson<String>(second),
    };
  }

  SavedWordPair copyWith({String? first, String? second}) => SavedWordPair(
        first: first ?? this.first,
        second: second ?? this.second,
      );
  @override
  String toString() {
    return (StringBuffer('SavedWordPair(')
          ..write('first: $first, ')
          ..write('second: $second')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(first, second);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedWordPair &&
          other.first == this.first &&
          other.second == this.second);
}

class SavedWordPairsCompanion extends UpdateCompanion<SavedWordPair> {
  final Value<String> first;
  final Value<String> second;
  const SavedWordPairsCompanion({
    this.first = const Value.absent(),
    this.second = const Value.absent(),
  });
  SavedWordPairsCompanion.insert({
    required String first,
    required String second,
  })  : first = Value(first),
        second = Value(second);
  static Insertable<SavedWordPair> custom({
    Expression<String>? first,
    Expression<String>? second,
  }) {
    return RawValuesInsertable({
      if (first != null) 'first': first,
      if (second != null) 'second': second,
    });
  }

  SavedWordPairsCompanion copyWith(
      {Value<String>? first, Value<String>? second}) {
    return SavedWordPairsCompanion(
      first: first ?? this.first,
      second: second ?? this.second,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (first.present) {
      map['first'] = Variable<String>(first.value);
    }
    if (second.present) {
      map['second'] = Variable<String>(second.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedWordPairsCompanion(')
          ..write('first: $first, ')
          ..write('second: $second')
          ..write(')'))
        .toString();
  }
}

class $SavedWordPairsTable extends SavedWordPairs
    with TableInfo<$SavedWordPairsTable, SavedWordPair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedWordPairsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _firstMeta = const VerificationMeta('first');
  @override
  late final GeneratedColumn<String?> first = GeneratedColumn<String?>(
      'first', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _secondMeta = const VerificationMeta('second');
  @override
  late final GeneratedColumn<String?> second = GeneratedColumn<String?>(
      'second', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [first, second];
  @override
  String get aliasedName => _alias ?? 'saved_word_pairs';
  @override
  String get actualTableName => 'saved_word_pairs';
  @override
  VerificationContext validateIntegrity(Insertable<SavedWordPair> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('first')) {
      context.handle(
          _firstMeta, first.isAcceptableOrUnknown(data['first']!, _firstMeta));
    } else if (isInserting) {
      context.missing(_firstMeta);
    }
    if (data.containsKey('second')) {
      context.handle(_secondMeta,
          second.isAcceptableOrUnknown(data['second']!, _secondMeta));
    } else if (isInserting) {
      context.missing(_secondMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {first, second};
  @override
  SavedWordPair map(Map<String, dynamic> data, {String? tablePrefix}) {
    return SavedWordPair.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SavedWordPairsTable createAlias(String alias) {
    return $SavedWordPairsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $SavedWordPairsTable savedWordPairs = $SavedWordPairsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedWordPairs];
}
