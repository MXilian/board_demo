import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/ui/blocs/main_bloc.dart';
import 'package:trello_demo/ui/screens/auth.dart';
import 'package:trello_demo/ui/screens/board.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        primaryColorDark: Colors.indigo,
        accentColor: Colors.lightBlueAccent,
        backgroundColor: Colors.black87,
        cardColor: Colors.white24,
        errorColor: Colors.red,
        buttonColor: Colors.white60,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => MainBloc(),
      child: SafeArea(
        child: BlocBuilder<MainBloc, MainBlocState>(
            builder: (context, state) {
              if (state.page == Screen.auth || state.page == Screen.register)
                return AuthScreen();
              else if (state.page == Screen.board)
                return BoardScreen();
              else
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white12,
                  child: CircularProgressIndicator(),
                );
            }),
      ),
    );
  }
}
