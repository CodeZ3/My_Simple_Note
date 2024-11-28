import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/notes_app_screen.dart';

void main() {
  runApp(const MySimpleNote());
}

class MySimpleNote extends StatelessWidget {
  const MySimpleNote({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Simple Notes',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),

      home: NotesAppScreen(),
    );
  }
}
