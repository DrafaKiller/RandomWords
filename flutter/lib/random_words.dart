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

  @override
  void initState() {
    super.initState();
    fetchSavedWords();
  }
  
  @override
  Widget build(BuildContext context) {
    Database database = ref.watch(databaseProvider);
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
              String word = _suggestions[index];
              final isSaved = savedWords.any((savedWord) => savedWord.word == word);
              return RandomWordRow(
                word: word,
                saved: isSaved,
                onSave: () async {
                  if (await widget.api.addSavedWord(word)) {
                    database.addSaveWordByName(word);
                  }
                },
                onUnsave: () async {
                  if (await widget.api.removeSavedWord(word)) {
                    database.removeSavedWordByName(word);
                  }
                }
              );
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

  void _openSaved() {
    Database database = ref.watch(databaseProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StreamBuilder<List<SavedWord>>(
            stream: database.watchSavedWords(),
            builder: (context, snapshot) {
              List<SavedWord> savedWords = snapshot.data ?? [];
              final tiles = savedWords.map((word) => ListTile(
                key: ValueKey(word),
                title: Text(word.word, style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.delete, semanticLabel: 'Remove from saved'),
                onTap: () async {
                  if (await widget.api.removeSavedWord(word.word)) {
                    database.removeSavedWord(word);
                  }
                }
              )).toList();

              if (savedWords.isEmpty) {
                tiles.add(const ListTile(
                  title: Center(child: Text("No suggestions saved"))
                ));
              }

              return Scaffold(
                appBar: AppBar(title: const Text('Saved Suggestions')),
                body: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) => tiles[index],
                  separatorBuilder: (context, index) => const Divider(),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    String? currentWord;
                    final word = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return ProviderScope(
                          child: AlertDialog(
                            title: const Text('Add a word'),
                            content: TextField(
                              autofocus: true,
                              decoration: const InputDecoration(labelText: 'Word'),
                              onChanged: (value) => currentWord = value
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop()
                              ),
                              TextButton(
                                child: const Text('Add'),
                                onPressed: () => Navigator.of(context).pop(currentWord)
                              )
                            ]
                          ),
                        );
                      }
                    );

                    if (word != null) {
                      if (await widget.api.addSavedWord(word)) {
                        database.addSaveWordByName(word);
                      }
                    }
                  }
                ),
              );
            }
          );
        },
      ),
    );
  }

  void fetchSavedWords() async {
    List<String>? savedWords = await widget.api.getSavedWords();
    if (savedWords != null) {
      Database database = ref.read(databaseProvider);
      database.removeAllSavedWords();
      for (String word in savedWords) {
        database.addSaveWordByName(word);
      }
      _suggestions.insertAll(0, savedWords);
    }
  }
}

class RandomWordRow extends StatelessWidget {
  final String word;
  final bool saved;

  final Future Function()? onSave;
  final Future Function()? onUnsave;

  const RandomWordRow({
    Key? key,
    required this.word, required this.saved,
    this.onSave, this.onUnsave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(word, style: const TextStyle(fontSize: 18)),
    trailing: Icon(
      saved ? Icons.favorite : Icons.favorite_border,
      color: saved ? Colors.red : null,
      semanticLabel: saved ? 'Remove from saved' : 'Save'
    ),
    onTap: () async {
      if (saved) {
        await onUnsave?.call();
      } else {
        await onSave?.call();
      }
    },
  );
}