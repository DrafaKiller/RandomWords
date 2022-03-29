import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);
  static var urlREST = Uri.parse('http://10.0.2.2:3000/');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Words',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),   
      home: const RandomWords()
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({ Key? key }) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <int, String>{};
  final _waitingRequests = <int, Future<String>>{};
  var _saved = <String>[];

  final _biggerFont = const TextStyle(fontSize: 18);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Words'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
        ]
      ),
      body: FutureBuilder<List<String>>(
        future: _getSavedWords(),
        builder: (context, savedWords) {
          if (savedWords.hasData) {
            _saved = savedWords.data!;
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (index.isOdd) return const Divider();
      
              final current = index ~/ 2;
              if (_suggestions.containsKey(current)) {
                return _buildRow(_suggestions[current]!);
              } else if (!_waitingRequests.containsKey(current)) {
                var request = _getWords();
                for (var index = current; index < current + 10; index++) {
                  _waitingRequests[index] = request.then((List<String> words) => words[index - current]);
                }
              }
              
              return FutureBuilder<String>(future: _waitingRequests[current], builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _waitingRequests.remove(current);
                  _suggestions[current] = snapshot.data!;
                  
                  return _buildRow(_suggestions[current]!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              });
            }
          );
        }
      )
    );
  }

  Widget _buildRow(String word) {
    return StatefulBuilder(
      builder: (context, setState) {
        final alreadySaved = _saved.contains(word);
        return ListTile(
          title: Text(word, style: _biggerFont),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
            semanticLabel: alreadySaved ? 'Remove from saved' : 'Save'
          ),
          onTap: () async {
              if (alreadySaved) {
                if (await _unsaveWord(word)) {
                  setState(() => _saved.remove(word));
                }
              } else {
                if (await _saveWord(word)) {
                  setState(() => _saved.add(word));
                }
              }
          },
        );
      }
    );
  }

  Future<List<String>> _getWords() async {
    var response = await http.get(MyApp.urlREST.resolve('/words'));

    var words = <String>[];
    if (response.statusCode == 200) {
        List<String> json = List.from(jsonDecode(response.body));
      words.addAll(json);
    }

    return words;
  }

  Future<List<String>> _getSavedWords() async {
    var words = <String>[];
    var response = await http.get(MyApp.urlREST.resolve('/users/1/favorites'));

    if (response.statusCode == 200) {
      List<String> json = List.from(jsonDecode(response.body));
      words.addAll(json);
    }
    
    return words;
  }

  Future<bool> _saveWord(String word) async {
    var response = await http.post(MyApp.urlREST.resolve('/users/1/favorites/$word'));
    return response.statusCode == 200;
  }

  Future<bool> _unsaveWord(String word) async {
    var response = await http.delete(MyApp.urlREST.resolve('/users/1/favorites/$word'));
    return response.statusCode == 200;
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final tiles = _saved.map((word) {
                return ListTile(
                  key: ValueKey(word),
                  title: Text(word, style: _biggerFont),
                  trailing: const Icon(Icons.delete, semanticLabel: 'Remove from saved'),
                  onTap: () async {
                    if (await _unsaveWord(word)) {
                      this.setState(() {
                        setState(() => _saved.remove(word));
                      });
                    }
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