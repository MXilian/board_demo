abstract class Connector {
  void configure({
    Function(dynamic requestOptions) onRequest,
    Function(dynamic response) onResponse,
    Function(dynamic requestOptions) onTokenDeprecated,
    Function(dynamic error) onError,
  });

  void setRequestToken(String token, dynamic requestOptions);

  dynamic get(String path, {Map<String, dynamic> params});

  dynamic post(String path, {Map<String, dynamic> params});

  dynamic patch(String path, {Map<String, dynamic> params});

  dynamic delete(String path);
}



