import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_words/api.dart';

import 'database/database.dart';

final databaseProvider = Provider<Database>((reference) {
  final Database database = Database();
  reference.onDispose(() => database.close());
  return database;
});

class RandomWords extends ConsumerStatefulWidget {
  final API api;
  final int wordsUpdateThreshold = 20;
  final int wordsUpdateAmount = 20;

  const RandomWords({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends ConsumerState<RandomWords> {
  final _suggestions = <String>[];
  bool _waitingForWords = false;

  final _biggerFont = const TextStyle(fontSize: 18);

  late final Database database = Database();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Words'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _openSaved,
            tooltip: 'Saved Suggestions',
          ),
        ]
      ),
      body: StreamBuilder<List<SavedWord>>(
        stream: database.watchSavedWords(),
        builder: (context, snapshot) {
          List<SavedWord> savedWords = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _suggestions.length + 1,
            itemBuilder: (context, index) {
              if (index > _suggestions.length - widget.wordsUpdateThreshold) {
                _requestWords();
              }
              if (index >= _suggestions.length) {
                return const ListTile(title: Center(child: CircularProgressIndicator()));
              }
              return _buildRow(_suggestions[index], savedWords.any((savedWord) => savedWord.word == _suggestions[index]));
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        }
      )
    );
  }

  void _requestWords() async {
    if (!_waitingForWords) {
      _waitingForWords = true;
      List<String>? words = await widget.api.getWords(amount: widget.wordsUpdateAmount);
      if (words != null) {
        setState(() {
          _suggestions.addAll(words);
        });
      }
      _waitingForWords = false;
    }
  }

  Widget _buildRow(String word, bool isSaved) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          title: Text(word, style: _biggerFont),
          trailing: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? Colors.red : null,
            semanticLabel: isSaved ? 'Remove from saved' : 'Save'
          ),
          onTap: () async {
            if (isSaved) {
              if (await widget.api.removeSavedWord(word)) {
                database.unsaveWordByName(word);
              }
            } else {
              if (await widget.api.addSavedWord(word)) {
                database.saveWordByName(word);
              }
            }
          },
        );
      }
    );
  }

  void _openSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StreamBuilder<List<SavedWord>>(
            stream: database.watchSavedWords(),
            builder: (context, snapshot) {
              List<SavedWord> savedWords = snapshot.data ?? [];
              final tiles = savedWords.map((word) => ListTile(
                key: ValueKey(word),
                title: Text(word.word, style: _biggerFont),
                trailing: const Icon(Icons.delete, semanticLabel: 'Remove from saved'),
                onTap: () async {
                  if (await widget.api.removeSavedWord(word.word)) {
                    database.unsaveWord(word);
                  }
                }
              )).toList();

              if (savedWords.isEmpty) {
                tiles.add(const ListTile(
                  title: Center(child: Text("No suggestions saved"))
                ));
              }

              final divided = tiles.isNotEmpty ? ListTile.divideTiles(context: context, tiles: tiles).toList() : <Widget>[];

              return Scaffold(
                appBar: AppBar(title: const Text('Saved Suggestions')),
                body: ListView(children: divided)
              );
            }
          );
        },
      ),
    );
  }
}