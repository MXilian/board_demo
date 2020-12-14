import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/data/models/card.dart';
import 'package:trello_demo/services/cards_cubit.dart';

abstract class CardScreenEvents {}
class CardScreenInit extends CardScreenEvents {}
class CardScreenSave extends CardScreenEvents {}
class CardScreenDiscard extends CardScreenEvents {}
class CardScreenUpdated extends CardScreenEvents {
  final CardModel card;
  CardScreenUpdated(this.card);
}

class CardScreenBloc extends Bloc<CardScreenEvents, CardModel> {
  final CardsCubit _cardsService;

  CardScreenBloc(CardModel card, this._cardsService) : super(card) {
    add(CardScreenInit());
  }

  StreamSubscription _cardsSubscription;

  final TextEditingController cardTextController = TextEditingController();

  @override
  Stream<CardModel> mapEventToState(CardScreenEvents event) async* {
    if (event is CardScreenInit) {
      cardTextController.text = state.text;
      _cardsSubscription?.cancel();
      _cardsSubscription = _cardsService.listen((cards) {
        CardModel _card = cards.firstWhere((e) => e.id == state.id ||
            e.text == cardTextController.text, orElse: () => null);
        if (_card != null)
          add(CardScreenUpdated(_card));
      });

    } else if (event is CardScreenSave) {
      _cardsService.updateCard(state.update(text: cardTextController.text));

    } else if (event is CardScreenDiscard) {
      cardTextController.text = state.text;
      cardTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: cardTextController.text.length));

    } else if (event is CardScreenUpdated) {
      cardTextController.text = event.card.text;
      cardTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: cardTextController.text.length));
      yield event.card;
    }
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    cardTextController?.dispose();
    return super.close();
  }
}