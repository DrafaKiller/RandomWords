import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AppDatabase(),
      child: MaterialApp(
        title: 'My Application - Test',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),   
        home: const RandomWords()
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({ Key? key }) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  Set<WordPair> _saved = <WordPair>{};
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  
  @override
  Widget build(BuildContext context) {
    Provider.of<AppDatabase>(context).watchSavedWordPairs().listen((event) {
      setState(() {
        _saved = event.toSet();
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Application - Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
        ]
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (index.isOdd) return const Divider();

          final current = index ~/ 2;
          if (current >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          return _buildRow(_suggestions[current]);
        },
      )
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
      
    return ListTile(
      title: Text(pair.asPascalCase, style: _biggerFont),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save'
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) Provider.of<AppDatabase>(context, listen: false).unsaveWordPair(pair);
          else Provider.of<AppDatabase>(context, listen: false).saveWordPair(pair);
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final tiles = _saved.map((pair) {
                return ListTile(
                  key: ValueKey(pair.asPascalCase),
                  title: Text(pair.asPascalCase, style: _biggerFont),
                  trailing: const Icon(Icons.delete, semanticLabel: 'Remove from saved'),
                  onTap: () {
                    this.setState(() {
                      setState(() {
                        Provider.of<AppDatabase>(context, listen: false).unsaveWordPair(pair);
                      });
                    });
                  }
                );
              });

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