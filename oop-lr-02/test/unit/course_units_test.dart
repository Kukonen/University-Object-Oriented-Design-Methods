import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:surf_mad_teacher_training/api/data/filter_places_request_dto.dart';
import 'package:surf_mad_teacher_training/api/data/place_dto.dart';
import 'package:surf_mad_teacher_training/api/data/place_type_dto.dart';
import 'package:surf_mad_teacher_training/api/service/api_client.dart';
import 'package:surf_mad_teacher_training/assets/strings/app_strings.dart';
import 'package:surf_mad_teacher_training/feature/common/data/converters/favorite_place_from_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/common/data/converters/favorite_place_to_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/filter/data/converters/filter_places_converter.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/domain/entities/onboarding_step_type.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/presentation/utils/extension/onboarding_step_extension.dart';
import 'package:surf_mad_teacher_training/feature/places/data/converters/place_response_converter.dart';
import 'package:surf_mad_teacher_training/feature/search/data/converters/search_keyword_from_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/search/data/converters/search_keyword_to_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/search/data/repositories/search_repository.dart';
import 'package:surf_mad_teacher_training/feature/settings/presentation/settings_model.dart';
import 'package:surf_mad_teacher_training/feature/theme_mode/domain/repositories/i_theme_mode_repository.dart';
import 'package:surf_mad_teacher_training/persistence/database/app_database.dart';

const _place = PlaceEntity(
  id: 15,
  name: 'Эрмитаж',
  description: 'Музей',
  type: PlaceType.museum,
  images: ['one.jpg', 'two.jpg'],
  lat: 59.9452,
  lon: 30.3245,
);

void main() {
  test('FavoritePlaceToDbConverter записывает значения доменной сущности', () {
    final row = const FavoritePlaceToDbConverter().convert(_place);
    expect(row.placeId.value, 15);
    expect(row.type.value, PlaceType.museum);
    expect(row.images.value, ['one.jpg', 'two.jpg']);
    expect(row.lat.value, _place.lat);
    expect(row.lon.value, _place.lon);
  });

  test('FavoritePlaceFromDbConverter читает строку с фотографиями', () {
    final row = FavoritePlacesTableData(
      id: 1,
      placeId: _place.id,
      name: _place.name,
      description: _place.description,
      type: _place.type,
      images: _place.images,
      lat: _place.lat,
      lon: _place.lon,
    );
    final result = const FavoritePlaceFromDbConverter().convert(row);
    expect(result.id, _place.id);
    expect(result.name, _place.name);
    expect(result.description, _place.description);
    expect(result.type, _place.type);
    expect(result.images, _place.images);
  });

  test('OnboardingStepExtension сопоставляет три шага с заголовками и ресурсами', () {
    final steps = OnboardingStepType.values;
    expect(steps.map((step) => step.title), [
      AppStrings.onboardingPage1Title,
      AppStrings.onboardingPage2Title,
      AppStrings.onboardingPage3Title,
    ]);
    expect(steps.map((step) => step.icon).toSet(), hasLength(3));
    expect(steps.every((step) => step.description.isNotEmpty), isTrue);
  });

  group('SearchRepository', () {
    late AppDatabase database;
    late _SearchApi api;
    late SearchRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      api = _SearchApi();
      repository = SearchRepository(
        apiClient: api,
        historySearchDao: database.historySearchDao,
        filterPlacesConverter: const FilterPlacesConverter(),
        placeResponseConverter: const PlaceResponseConverter(),
        fromDbConverter: const SearchKeywordFromDbConverter(),
        toDbConverter: const SearchKeywordToDbConverter(),
      );
    });
    tearDown(() async {
      repository.dispose();
      await database.close();
    });

    test('преобразует фильтр и результат запроса', () async {
      final result = await repository.getFilteredPlaces(
        filter: const FilterPlacesEntity(name: 'Эрм', type: {PlaceType.museum}),
      );
      expect(api.lastFilter?.nameFilter, 'Эрм');
      expect(api.lastFilter?.typeFilter, [PlaceTypeDto.museum]);
      expect(result.isOk, isTrue);
      expect(result.unwrap().single.name, _place.name);
    });

    test('сохраняет, удаляет и очищает историю', () async {
      await repository.saveKeyword(keyword: 'Парк');
      await repository.saveKeyword(keyword: 'Музей');
      await repository.saveKeyword(keyword: 'Музей');
      final history = await repository.historySearchStream.first;
      expect(history, hasLength(2));
      await repository.removeKeyword(keyword: history.first);
      expect(await repository.historySearchStream.first, hasLength(1));
      await repository.clearHistory();
      expect(await repository.historySearchStream.first, isEmpty);
    });
  });

  test('SettingsModel читает текущую тему и передаёт изменение в репозиторий', () async {
    final repository = _ThemeRepository();
    addTearDown(repository.dispose);
    final model = SettingsModel(themeModeRepository: repository);
    expect(model.currentThemeMode, ThemeMode.light);
    await model.setThemeMode(ThemeMode.dark);
    expect(model.currentThemeMode, ThemeMode.dark);
  });
}

class _SearchApi implements ApiClient {
  FilterPlacesRequestDto? lastFilter;

  @override
  Future<List<PlaceDto>> getFilteredPlaces({required FilterPlacesRequestDto filter}) async {
    lastFilter = filter;
    return [
      PlaceDto(
        id: _place.id,
        name: _place.name,
        description: _place.description,
        placeType: PlaceTypeDto.museum,
        images: _place.images,
        lat: _place.lat,
        lon: _place.lon,
      ),
    ];
  }

  @override
  Future<List<PlaceDto>> getPlaces() async => [];
}

class _ThemeRepository implements IThemeModeRepository {
  final _stream = BehaviorSubject.seeded(ThemeMode.light);
  @override
  ValueStream<ThemeMode> get themeModeStream => _stream.stream;
  @override
  Future<ThemeMode> getThemeMode() async => _stream.value;
  @override
  Future<void> setThemeMode(ThemeMode newThemeMode) async => _stream.add(newThemeMode);
  @override
  void dispose() => _stream.close();
}
