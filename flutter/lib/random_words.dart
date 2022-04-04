import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';



class RandomWords extends StatefulWidget {
  const RandomWords({ Key? key }) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];
  var _saved = <String>[];
  late Future<List<String>> _futureSaved;
  Future<List<String>>? _futureWords;
  final int _wordsUpdateThreshold = 20;
  final int _wordsUpdateAmount = 20;
  bool _initialized = false;

  // ver: lib rxdart

  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    _futureSaved = _getSavedWords();
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
      body: FutureBuilder<List<String>>(
        future: _futureSaved,
        builder: (context, savedWords) {
          if (savedWords.hasData && !_initialized) {
            _saved = savedWords.data!;
            for (int index = 0; index < _saved.length; index++) {
              _suggestions[index] = _saved[index];
            }
            _initialized = true;
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _suggestions.length + 1,
            itemBuilder: (context, index) {
              if (index > _suggestions.length - _wordsUpdateThreshold && _futureWords == null) {
                _futureWords = _getWords(amount: _wordsUpdateAmount);
                _futureWords!.then((value) {
                  setState(() {
                    _suggestions.addAll(value);
                    _futureWords = null;
                  });
                });
              }
              if (index >= _suggestions.length) {
                return const ListTile(title: Center(child: CircularProgressIndicator()));
              }
              return _buildRow(_suggestions[index]);
            },
            separatorBuilder: (context, index) => const Divider(),
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

  Future<List<String>> _getWords({int amount = 10}) async {
    var words = <String>[];

    var response = await http.get(MyApp.urlREST.resolve('/words?amount=$amount'), headers: { 'Authorization': MyApp.token! });
    if (response.statusCode == 200) {
        List<String> json = List.from(jsonDecode(response.body));
      words.addAll(json);
    }

    return words;
  }

  Future<List<String>> _getSavedWords() async {
    var words = <String>[];
    var response = await http.get(MyApp.urlREST.resolve('/users/${MyApp.userId}/favorites'), headers: { 'Authorization': MyApp.token! });

    if (response.statusCode == 200) {
      List<String> json = List.from(jsonDecode(response.body));
      words.addAll(json);
    }
    
    return words;
  }

  Future<bool> _saveWord(String word) async {
    var response = await http.post(MyApp.urlREST.resolve('/users/${MyApp.userId}/favorites/$word'), headers: { 'Authorization': MyApp.token! });
    return response.statusCode == 200;
  }

  Future<bool> _unsaveWord(String word) async {
    var response = await http.delete(MyApp.urlREST.resolve('/users/${MyApp.userId}/favorites/$word'), headers: { 'Authorization': MyApp.token! });
    return response.statusCode == 200;
  }

  void _openSaved() {
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
              }).toList();

              if (_saved.isEmpty) {
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