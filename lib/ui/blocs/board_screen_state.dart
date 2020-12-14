part of 'package:trello_demo/ui/blocs/board_screen_bloc.dart';

class BoardScreenState {
  final List<CardModel> cards;
  final List<Board> columns;

  static BoardScreenState get initial => BoardScreenState(
    cards: null,
    columns: [Board.on_hold, Board.in_progress, Board.needs_review, Board.approved],
  );

  BoardScreenState({
    @required this.cards,
    @required this.columns,
  });

  BoardScreenState _copyWith({
    List<CardModel> cards,
    List<Board> columns,
  }) => BoardScreenState(
    cards: cards ?? this.cards,
    columns: columns ?? this.columns,
  );
}