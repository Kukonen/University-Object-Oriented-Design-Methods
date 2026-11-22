import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surf_mad_teacher_training/api/api_retry_interceptor.dart';

void main() {
  test('два временных сбоя сменяются успешным ответом', () async {
    final adapter = _SequenceAdapter([503, 503, 200]);
    final dio = _client(adapter);
    addTearDown(dio.close);

    final answer = await dio.get<dynamic>('/place');

    expect(answer.statusCode, 200);
    expect(adapter.calls, 3);
  });

  test('чтение по POST исчерпывает лимит повторов', () async {
    final adapter = _SequenceAdapter([503, 503, 503]);
    final dio = _client(adapter);
    addTearDown(dio.close);

    await expectLater(dio.post<dynamic>('/filtered_places'), throwsA(isA<DioException>()));
    expect(adapter.calls, 3);
  });

  test('404 и операция записи не повторяются', () async {
    final adapter = _SequenceAdapter([404, 503]);
    final dio = _client(adapter);
    addTearDown(dio.close);

    await expectLater(dio.get<dynamic>('/place/99'), throwsA(isA<DioException>()));
    await expectLater(dio.post<dynamic>('/place'), throwsA(isA<DioException>()));
    expect(adapter.calls, 2);
  });
}

Dio _client(_SequenceAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888', responseType: ResponseType.plain))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(ApiRetryInterceptor(dio));
  return dio;
}

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this.statuses);

  final List<int> statuses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{}', statuses[calls++]);

  @override
  void close({bool force = false}) {}
}
