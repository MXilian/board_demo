import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/data/models/card.dart';
import 'package:trello_demo/ui/blocs/card_screen_bloc.dart';
import 'package:trello_demo/ui/blocs/main_bloc.dart';

class CardScreen extends StatelessWidget {
  final CardModel _card;
  final MainBloc _mainBloc;
  CardScreen(this._card, this._mainBloc);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mainBloc,
      child: BlocBuilder<MainBloc, MainBlocState>(
        builder: (context, state) {
          if (state.page != Screen.board)
            Navigator.pop(context);

          return BlocProvider(
            create: (_) => CardScreenBloc(
              _card,
              _mainBloc.cardsService,
            ),
            child: BlocBuilder<CardScreenBloc, CardModel>(
              builder: (context, card) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    title: Text('Editing mode'),
                  ),
                  body: Container(
                    padding: EdgeInsets.only(bottom: 16.0),
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                            child: TextFormField(
                              style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.77)),
                              controller: BlocProvider.of<CardScreenBloc>(context)
                                  .cardTextController,
                              maxLines: 999,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                    'Discard changes',
                                  style: TextStyle(fontSize: 18),
                                ),
                                color: Theme.of(context).errorColor.withOpacity(0.44),
                                onPressed: () {
                                  BlocProvider.of<CardScreenBloc>(context)
                                      .add(CardScreenDiscard());
                                },
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  'Save changes',
                                  style: TextStyle(fontSize: 18),
                                ),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  BlocProvider.of<CardScreenBloc>(context)
                                      .add(CardScreenSave());
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
    );
  }
}