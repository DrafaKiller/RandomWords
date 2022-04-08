import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_words/random_words.dart';

import 'login.dart';

import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

DynamicLibrary _openOnWindows() {
  final script = File(Platform.script.toFilePath());
  final libraryNextToScript = File('${script.path}/sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      onLogin: (api) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => RandomWords(api: api),
          ),
        );
      }
    );
  }
}