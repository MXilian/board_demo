import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trello_demo/data/abstracts/connector.dart';
import 'package:trello_demo/data/models/error.dart';
import 'package:trello_demo/data/values/constants.dart';

class AuthCubit extends Cubit<String> {
  final Connector _connector;
  final SharedPreferences _preferences;

  AuthCubit(this._connector, this._preferences) : super(null) {
    _connector.configure(
      onRequest: (requestOptions) {
        _connector.setRequestToken(token, requestOptions);
      },
      onResponse: (response) {
        print('RESPONSE: ${response.data}');
      },
      onTokenDeprecated: (requestOptions) {
        refreshToken();
        _connector.setRequestToken(token, requestOptions);
      },
      onError: (error) {
        print('ERROR: ${error.message}');
        if ((error.message as String).contains('SocketException')) {
          emit(null);
          // В случае ошибки подключения будут предприниматься попытки
          // повторного подключения каждые 3 секунды
          _timer?.cancel();
          _timer = Timer(Duration(seconds: 3), () {
            _loadToken();
          });
        }
      },
    );
    _loadToken();
  }

  String get token => state;
  bool get isAuthorized => token != null;

  Timer _timer;

  void _loadToken() {
    String savedToken = _preferences.getString(KEY_TOKEN);
    if (savedToken != null && savedToken.isNotEmpty) {
      emit(savedToken);
      refreshToken();
    }
  }

  void _saveToken() {
    _preferences.setString(KEY_TOKEN, token ?? '');
  }

  Future registerAndLogin({
    @required String username, String email, @required String password,
  }) async {
    Map<String, dynamic> params = {
      'username': username,
      'password': password,
    };
    if (email != null)
      params['email'] = email;
    var response = await _connector.post('/users/create/', params: params);
    if (response is ErrorMsg) {
      return response.text;
    } else if (response != null) {
      emit(response['token']);
      _saveToken();
    }
  }

  Future login({@required String username, @required String password}) async {
    Map<String, dynamic> params = {
      'username': username,
      'password': password,
    };
    var response = await _connector.post('/users/login/', params: params);
    if (response is ErrorMsg) {
      return response.text;
    } else if (response != null) {
      // Api почему-то не возвращает обещанный логин юзера, приходит только токен
      emit(response['token']);
      _saveToken();
    }
  }

  Future refreshToken() async {
    if (token != null) {
      var result = await _connector.post('/users/refresh_token/',
          params: {'token': token});
      if (result is ErrorMsg) {
        return result.text;
      } else if (result != null) {
        emit(result['token']);
        _saveToken();
        return;
      }
    }
    logout();
  }

  void logout() {
    emit(null);
    _saveToken();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _saveToken();
    return super.close();
  }
}