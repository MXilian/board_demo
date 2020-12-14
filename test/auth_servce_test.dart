import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trello_demo/abstracts/connector.dart';
import 'package:trello_demo/services/auth_cubit.dart';
import 'package:trello_demo/services/dio_provider.dart';

void main() {
  test('auth_cubit_test', () async {
    final String username = 'armada';
    final String password = 'FSH6zBZ0p9yH';
    final Connector connector = DioProvider();
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final service = AuthCubit(connector, preferences);

    if (!service.isAuthorized)
      await service.login(username: username, password: password);
    else
      print('Already authorized. Token: ${service.token}');

    expect(service.token != null && service.token.isNotEmpty, true);
  });

  test('logout_test', () async {
    final Connector connector = DioProvider();
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final service = AuthCubit(connector, preferences);

    if (service.isAuthorized) {
      service.logout();
    } else
      print('Already unauthorized!');

    print('Success logout: ${service.token == null}');

    expect(service.token == null || service.token.isEmpty, true);
  });
}