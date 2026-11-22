import 'package:dio/dio.dart';

/// Создаёт один клиент приложения с едиными таймаутами.
class AppDioConfigurator {
  const AppDioConfigurator();

  Dio create({required Iterable<Interceptor> interceptors, required String url}) {
    const timeout = Duration(seconds: 30);
    final dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      ),
    );
    dio.interceptors.addAll(interceptors);
    return dio;
  }
}
