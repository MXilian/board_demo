import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/data/abstracts/connector.dart';
import 'package:trello_demo/data/models/card.dart';
import 'package:trello_demo/data/models/error.dart';
import 'package:trello_demo/data/values/board.dart';

class CardsCubit extends Cubit<List<CardModel>> {
  final Connector _connector;

  CardsCubit(this._connector) : super([]);

  List<CardModel> get cards => state;

  Timer _timer;

  void _autoUpdate() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 7), () {
      getAllCards().then((_) {
        _autoUpdate();
      });
    });
  }

  void stopAutoUpdate() {
    print('Auto updates stopped');
    _timer?.cancel();
  }
  void runAutoUpdate() {
    print('Auto updates resumed');
    _autoUpdate();
  }

  Future getAllCards() async {
    var response = await _connector.get('/cards/');
    if (response != null && response is !ErrorMsg)
      emit(CardModel.fromJsonToList(response));
  }

  Future<List<CardModel>> getCardsByColumn(Board boardColumn) async {
    Map<String, dynamic> params = {'row': boardColumn.toInt};
    var response = await _connector.get('/cards/', params: params);
    if (response != null && response is !ErrorMsg)
      return CardModel.fromJsonToList(response);
    else
      return [];
  }

  Future createCard({@required Board boardColumn, @required String text}) async {
    Map<String, dynamic> params = {
      'row': boardColumn.toInt,
      'text': text,
    };
    var response = await _connector.post('/cards/', params: params);
    if (response != null && response is !ErrorMsg) {
      CardModel newCard = CardModel.fromJson(response);
      List<CardModel> newList = []..addAll(cards)..add(newCard);
      emit(newList);
    }
  }

  Future updateCard(CardModel card) async {
    /// Не смотря на возвращаемый status code 200 при попытке обновить карточку,
    /// она по факту все равно не обновляется - видимо на бэке какой-то баг :-\
    /// Потому, как временное решение, удаляем карточку и создаем новый экземпляр:
    deleteCard(card.id);
    createCard(boardColumn: card.column, text: card.text);
    /// Нормальное решение пока закомментил:
    //
    // Map<String, dynamic> params = {
    //   'row': card.column.toInt,
    //   'sew_num': card.seqNum,
    //   'text': card.text,
    // };
    // var response = await _connector.patch('/cards/${card.id}/', params: params);
    // if (response != null && response is !ErrorMsg) {
    //   CardModel oldCard = cards.firstWhere((e) => e.id == card.id, orElse: () => null);
    //   CardModel newCard = CardModel.fromJson(response).update(id: card.id);
    //   List<CardModel> newList = [];
    //   newList..addAll(cards)
    //     ..remove(oldCard)
    //     ..add(newCard);
    //   emit(newList);
    // }
  }

  Future deleteCard(int id) async {
    var result = await _connector.delete('/cards/$id/');
    if (result == true) {
      CardModel deletedCard = cards.firstWhere((e) => e.id == id, orElse: () => null);
      List<CardModel> newList = []..addAll(cards)..remove(deletedCard);
      emit(newList);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}