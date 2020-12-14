import 'package:trello_demo/data/values/board.dart';

class CardModel {
  final int id;
  final Board column;
  final int seqNum;
  final String text;

  CardModel({
    this.id,
    this.column,
    this.seqNum,
    this.text,
  });

  CardModel update({
    int id,
    Board column,
    final int seqNum,
    final String text,
  }) => CardModel(
    id: id ?? this.id,
    column: column ?? this.column,
    seqNum: seqNum ?? this.seqNum,
    text: text ?? this.text,
  );

  static CardModel fromJson(Map<String, dynamic> json) => CardModel(
    id: json['id'] as int,
    column: BoardExt.fromString(json['row']),
    seqNum: json['seq_num'] as int,
    text: json['text'] as String,
  );

  static List<CardModel> fromJsonToList(dynamic json) =>
      (json as List).map((e) => CardModel.fromJson(e)).toList();
}