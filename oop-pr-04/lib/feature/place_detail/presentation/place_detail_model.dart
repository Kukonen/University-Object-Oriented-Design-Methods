import 'package:surf_mad_teacher_training/api/service/api_client.dart';
import 'package:surf_mad_teacher_training/core/data/repositories/base_repository.dart';
import 'package:surf_mad_teacher_training/core/domain/entities/result/request_operation.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/places/data/converters/place_response_converter.dart';

/// Загружает актуальную карточку выбранного места.
final class PlaceDetailModel extends BaseRepository {
  const PlaceDetailModel(this._apiClient, this._converter);

  final ApiClient _apiClient;
  final IPlaceResponseConverter _converter;

  RequestOperation<PlaceEntity> load(int id) =>
      makeApiCall(() async => _converter.convert(await _apiClient.getPlaceDetails(id)));
}
