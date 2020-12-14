import 'package:dio/dio.dart';
import 'package:trello_demo/data/abstracts/connector.dart';
import 'package:trello_demo/data/models/error.dart';
import 'package:trello_demo/data/values/constants.dart';

class DioProvider extends Connector {
  final Dio _dio = Dio();

  @override
  void configure({
    Function(dynamic requestOptions) onRequest,
    Function(dynamic response) onResponse,
    Function(dynamic requestOptions) onTokenDeprecated,
    Function(dynamic error) onError
  }) {
    _dio.options.baseUrl = API_URL;
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) {
          onRequest(options);
          return options;
        },
        onResponse: (Response response) {
          onResponse(response);
          return response;
        },
        onError: (DioError error) async {
          if (error.response?.statusCode == 403) {
            _dio.interceptors.requestLock.lock();
            _dio.interceptors.responseLock.lock();
            RequestOptions options = error.response.request;
            onTokenDeprecated(options);
            _dio.interceptors.requestLock.unlock();
            _dio.interceptors.responseLock.unlock();
            return _dio.request(options.path, options: options);
          } else {
            onError(error);
            return error;
          }
        }
    ));
  }

  @override
  void setRequestToken(String token, dynamic options) {
    _dio.options.headers["Authorization"] = '$KEY_AUTH $token';
  }

  @override
  dynamic get(String path, {Map<String, dynamic> params}) async {
    Response response;
    try {
      response = await _dio.get(path, queryParameters: params);
    } on DioError catch(error) {
      return ErrorMsg(error.error);
    }
    if (response.statusCode == 200)
      return response.data;
    return null;
  }

  @override
  dynamic post(String path, {Map<String, dynamic> params}) async {
    Response response;
    try {
      response = await _dio.post(path, data: params);
    } on DioError catch(error) {
      return ErrorMsg(error.response?.data?.toString() ?? error.message);
    }
    if (response.statusCode == 200 || response.statusCode == 201)
      return response.data;
    return null;
  }

  @override
  dynamic patch(String path, {Map<String, dynamic> params}) async {
    Response response;
    try {
      response = await _dio.patch(path, data: params);
    } on DioError catch(error) {
      return ErrorMsg(error.response?.data?.toString() ?? error.message);
    }
    if (response.statusCode == 200)
      return response.data;
    return null;
  }

  @override
  dynamic delete(String path) async {
    Response response;
    try {
      response = await _dio.delete(path);
    } on DioError catch(error) {
      return ErrorMsg(error.response?.data?.toString() ?? error.message);
    }
    if (response.statusCode == 204)
      return true;
    return false;
  }

  void dispose() {
    _dio?.close(force: true);
  }
}