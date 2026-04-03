import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // NOTE: In Emulator, 10.0.2.2 connects to actual localhost. 
    // If testing on a real physical device, use external IP: http://194.163.154.2/api
    baseUrl: 'https://localhost:7153/api', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        log('=> ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('<= ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log('!! ERROR ${e.response?.statusCode} => ${e.requestOptions.path}');
        if (e.response?.statusCode == 401) {
          // Token expired or invalid -> trigger logout redirect
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}
