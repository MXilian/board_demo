import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/data/models/card.dart';
import 'package:trello_demo/data/values/board.dart';
import 'package:trello_demo/data/values/constants.dart';
import 'package:trello_demo/services/cards_cubit.dart';

part 'package:trello_demo/ui/blocs/board_screen_events.dart';
part 'package:trello_demo/ui/blocs/board_screen_state.dart';

class BoardScreenBloc extends Bloc<BoardScreenEvent, BoardScreenState> {
  final CardsCubit _cardsService;

  BoardScreenBloc(this._cardsService, {@required Function(CardModel) onOpenCard}) : super(BoardScreenState.initial) {
    _onOpenCard = onOpenCard;
    add(BoardScreenInit());
  }

  final ScrollController scrollController = ScrollController();

  Function(CardModel) _onOpenCard;
  StreamSubscription _cardsSubscription;

  @override
  Stream<BoardScreenState> mapEventToState(BoardScreenEvent event) async* {
    if (event is BoardScreenInit) {
      _cardsSubscription?.cancel();
      _cardsSubscription = _cardsService.listen((cards) {
        cards.sort((a, b) => a.seqNum.compareTo(b.seqNum));
        add(BoardScreenCardsUpdated(cards));
      });
    }

    if (event is BoardScreenCardsUpdated) {
      yield state._copyWith(cards: event.cards);
    }

    if (event is BoardScreenOpenCard) {
      _cardsService.stopAutoUpdate();
      _onOpenCard.call(event.card);
    }

    if (event is BoardScreenResume) {
      _cardsService.runAutoUpdate();
      _cardsService.getAllCards();
    }

    if (event is BoardScreenCreateCard) {
      // yield state._copyWith(cards: state.cards..add(CardModel(text: 'New card',
      //     seqNum: state.cards.last.seqNum + 1)));
      _cardsService.createCard(boardColumn: event.column, text: 'New card').then((_) {
        scrollController.animateTo(scrollController.position.maxScrollExtent + 100,
            duration: Duration(milliseconds: ANIM_DURATION_MS), curve: Curves.fastOutSlowIn);
      });
    }

    if (event is BoardScreenDeleteCard) {
      _cardsService.deleteCard(event.card.id);
    }
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    scrollController?.dispose();
    return super.close();
  }
}