import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trello_demo/data/abstracts/connector.dart';
import 'package:trello_demo/services/auth_cubit.dart';
import 'package:trello_demo/services/cards_cubit.dart';
import 'package:trello_demo/services/dio_provider.dart';

void main() {
  test('cards_service-test', () async {
    final String username = 'armada';
    final String password = 'FSH6zBZ0p9yH';
    final Connector connector = DioProvider();
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final authService = AuthCubit(connector, preferences);

    // if (authService.isAuthorized == false)
      await authService.login(username: username, password: password);

    final cardService = CardsCubit(connector);

    await cardService.getAllCards();

    print('cards: ${cardService.cards.length}');

    expect(cardService.cards.length > 0, true);
  });
}