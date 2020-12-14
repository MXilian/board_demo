import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/data/models/card.dart';
import 'package:trello_demo/data/values/board.dart';
import 'package:trello_demo/ui/blocs/board_screen_bloc.dart';
import 'package:trello_demo/ui/blocs/main_bloc.dart';
import 'package:trello_demo/ui/screens/card.dart';

class BoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Function onResume;

    // ignore: close_sinks
    var bloc = BlocProvider.of<MainBloc>(context);

    return BlocProvider(
      create: (_) => BoardScreenBloc(
        bloc.cardsService,
        onOpenCard: (CardModel card) {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) => CardScreen(
                card,
                bloc,
              ),
            ),
          ).then((_) {
            onResume.call();
          });
        },
      ),
      child: BlocBuilder<BoardScreenBloc, BoardScreenState>(
          builder: (context, state) {
        if (onResume == null)
          onResume = () {
            BlocProvider.of<BoardScreenBloc>(context).add(BoardScreenResume());
          };

        return DefaultTabController(
          length: state.columns.length,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColorDark,
              title: Text('Board'),
              actions: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 100,
                  height: 40,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    color: Theme.of(context).errorColor.withOpacity(0.66),
                    child: Text('Logout', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      BlocProvider.of<MainBloc>(context)
                          .add(MainBlocEvents.logout_pressed);
                    },
                  ),
                ),
              ],
              bottom: TabBar(
                tabs: List.generate(
                    state.columns.length,
                    (index) => Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                        child: Text(state.columns[index].title,
                          style: TextStyle(fontSize: 11),),
                      )),
              ),
            ),
            body: TabBarView(
              children: List.generate(state.columns.length, (index) {
                if (state.cards == null)
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.black87,
                    child: CircularProgressIndicator(),
                  );

                List<CardModel> cards = state.cards
                    .where((e) => e.column == state.columns[index])
                    .toList();

                return Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      color: Theme.of(context).backgroundColor,
                      child: ListView.builder(
                        controller: BlocProvider.of<BoardScreenBloc>(context)
                            .scrollController,
                        itemCount: cards.length,
                        itemBuilder: (context, i) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  BlocProvider.of<BoardScreenBloc>(context)
                                      .add(BoardScreenOpenCard(cards[i]));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Theme.of(context).cardColor,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(cards[i].text),
                                  ),
                                  margin: EdgeInsets.only(bottom: 1.0),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                width: 60,
                                height: 20,
                                margin: EdgeInsets.only(bottom: 12.0),
                                child: RaisedButton(
                                  padding: EdgeInsets.zero,
                                  color: Theme.of(context).errorColor.withOpacity(0.44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                  onPressed: () {
                                    BlocProvider.of<BoardScreenBloc>(context)
                                        .add(BoardScreenDeleteCard(cards[i]));
                                  },
                                  child: Text('X Delete', style: TextStyle(fontSize: 12),),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      margin: EdgeInsets.only(bottom: 28, right: 28),
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          BlocProvider.of<BoardScreenBloc>(context)
                              .add(BoardScreenCreateCard(state.columns[index]));
                        },
                        child: Icon(Icons.add),
                      ),
                    )
                  ],
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}
