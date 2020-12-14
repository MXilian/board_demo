part of 'package:trello_demo/ui/blocs/board_screen_bloc.dart';

abstract class BoardScreenEvent {}

class BoardScreenInit extends BoardScreenEvent {}

class BoardScreenCardsUpdated extends BoardScreenEvent {
  final List<CardModel> cards;
  BoardScreenCardsUpdated(this.cards);
}

class BoardScreenOpenCard extends BoardScreenEvent {
  final CardModel card;
  BoardScreenOpenCard(this.card);
}

class BoardScreenCreateCard extends BoardScreenEvent {
  final Board column;
  BoardScreenCreateCard(this.column);
}

class BoardScreenResume extends BoardScreenEvent {}

class BoardScreenDeleteCard extends BoardScreenEvent {
  final CardModel card;
  BoardScreenDeleteCard(this.card);
}