import 'package:dio/dio.dart';
import 'package:surf_mad_teacher_training/api/constants/api_urls.dart';

/// Повторяет временно недоступные операции чтения не более двух раз.
class ApiRetryInterceptor extends Interceptor {
  ApiRetryInterceptor(this._dio);

  static const _attemptKey = 'placesRetryAttempt';
  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final attempt = request.extra[_attemptKey] as int? ?? 0;
    final readOnly = request.method == 'GET' || (request.method == 'POST' && request.path == ApiUrls.filteredPlaces);
    final status = err.response?.statusCode;
    final temporary = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => status == 502 || status == 503 || status == 504,
      _ => false,
    };
    if (!readOnly || !temporary || attempt >= 2 || (request.cancelToken?.isCancelled ?? false)) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 300 * (1 << attempt)));
    final next = request.copyWith(extra: {...request.extra, _attemptKey: attempt + 1});
    try {
      handler.resolve(await _dio.fetch<dynamic>(next));
    } on DioException catch (failure) {
      handler.reject(failure);
    }
  }
}
