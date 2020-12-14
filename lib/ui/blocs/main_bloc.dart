import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trello_demo/services/auth_cubit.dart';
import 'package:trello_demo/services/cards_cubit.dart';
import 'package:trello_demo/services/dio_provider.dart';

enum MainBlocEvents {
  init,
  login_tab_selected,
  register_tab_selected,
  login_pressed,
  register_pressed,
  logout_pressed,
  _open_auth_page,
  _open_board_page,
}

enum Screen {
  none,
  auth,
  register,
  board,
}

class MainBlocState {
  final Screen page;
  final String error;
  MainBlocState({this.page = Screen.none, this.error});

  MainBlocState _copyWith({Screen page, String error}) => MainBlocState(
    page: page ?? this.page,
    error: error ?? this.error,
  );
}


class MainBloc extends Bloc<MainBlocEvents, MainBlocState> {
  MainBloc() : super(MainBlocState()) {
    add(MainBlocEvents.init);
  }

  AuthCubit _authService;
  AuthCubit get authService => _authService;

  CardsCubit _cardsService;
  CardsCubit get cardsService => _cardsService;

  DioProvider _connector;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  StreamSubscription _authStatusSubscription;

  String validateUsername(String text) {
    if(text.length < 4)
      return 'Minimum is 4 characters';
    else if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text))
      return null;
    return 'Allowed only A-Z characters and numbers';
  }

  String validatePassword(String text) {
    if(text.length < 8)
      return 'Minimum is 8 characters';
    else if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text))
      return null;
    return 'Allowed only A-Z characters and numbers';
  }

  String validateEmail(String text) {
    if (text.isEmpty)
      return 'Email is required';
    else if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(text))
      return null;
    return 'Incorrect email';
  }

  @override
  Stream<MainBlocState> mapEventToState(MainBlocEvents event) async* {

    if (event == MainBlocEvents.init) {
      _connector = DioProvider();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _authService = AuthCubit(_connector, preferences);
      _cardsService = CardsCubit(_connector);
      _authStatusSubscription?.cancel();
      _authStatusSubscription = _authService.listen((String token) {
        if (token == null)
          add(MainBlocEvents._open_auth_page);
        else
          add(MainBlocEvents._open_board_page);
      });
      if (_authService.state == null)
        yield state._copyWith(page: Screen.auth);

    } else if (event == MainBlocEvents.login_pressed) {
      if (validateUsername(usernameController.text) == null
          && validatePassword(passwordController.text) == null) {
        var result = await _authService.login(
            username: usernameController.text,
            password: passwordController.text
        );
        yield state._copyWith(error: result);
      }

    } else if (event == MainBlocEvents.logout_pressed) {
      usernameController.text = '';
      emailController.text = '';
      passwordController.text = '';
      _authService.logout();

    } else if (event == MainBlocEvents.register_pressed) {
      if (validateUsername(usernameController.text) == null
          && validatePassword(passwordController.text) == null
          && validateEmail(emailController.text) == null) {
        var result = await _authService.registerAndLogin(
          username: usernameController.text,
          password: passwordController.text,
          email: emailController.text,
        );
        yield state._copyWith(error: result);
      }

    } else if (event == MainBlocEvents.login_tab_selected) {
      yield MainBlocState(page: Screen.auth);

    } else if (event == MainBlocEvents.register_tab_selected) {
      yield MainBlocState(page: Screen.register);

    } else if (event == MainBlocEvents._open_auth_page) {
      cardsService.stopAutoUpdate();
      yield MainBlocState(page: Screen.auth);

    } else if (event == MainBlocEvents._open_board_page) {
      cardsService.runAutoUpdate();
      yield MainBlocState(page: Screen.board);

    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    _authService?.close();
    _cardsService?.close();
    _connector?.dispose();
    return super.close();
  }
}