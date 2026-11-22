import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_mad_teacher_training/api/data/filter_places_request_dto.dart';
import 'package:surf_mad_teacher_training/api/data/place_type_dto.dart';
import 'package:surf_mad_teacher_training/feature/common/data/converters/favorite_place_to_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/search/data/converters/search_keyword_to_db_converter.dart';
import 'package:surf_mad_teacher_training/persistence/database/app_database.dart';
import 'package:surf_mad_teacher_training/persistence/filter_storage/filter_storage.dart';
import 'package:surf_mad_teacher_training/persistence/theme_storage/theme_mode_storage.dart';

const _filter = FilterPlacesRequestDto(
  lat: 59.94,
  lng: 30.32,
  radius: 1500,
  nameFilter: 'музей',
  typeFilter: [PlaceTypeDto.museum],
);
const _place = PlaceEntity(
  id: 1,
  name: 'Эрмитаж',
  description: 'Музей',
  type: PlaceType.museum,
  images: [],
  lat: 59.94,
  lon: 30.32,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('схема 1 обновляется до 2, сохраняя избранное и историю', () async {
    final folder = await Directory.systemTemp.createTemp('guap_drift_test_');
    addTearDown(() => folder.delete(recursive: true));
    final file = File('${folder.path}/places.sqlite');

    final old = AppDatabase.forTesting(NativeDatabase(file));
    await old.favoritesDao.addFavorite(const FavoritePlaceToDbConverter().convert(_place));
    await old.historySearchDao.saveKeyword(const SearchKeywordToDbConverter().convert('Эрмитаж'));
    await old.customStatement('DROP TABLE filter_settings_table');
    await old.customStatement('PRAGMA user_version = 1');
    await old.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopened.close);
    final version = await reopened.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 2);
    expect((await reopened.favoritesDao.fetchFavorites()).single.name, 'Эрмитаж');
    expect((await reopened.historySearchDao.historySearchStream.first).single.keyword, 'Эрмитаж');
    expect(await reopened.filterSettingsDao.presets(), isEmpty);
    await reopened.historySearchDao.clearHistory();
    expect(await reopened.historySearchDao.historySearchStream.first, isEmpty);
  });

  test('миграция старого ключа выполняется один раз, фильтр читается после открытия файла', () async {
    SharedPreferences.setMockInitialValues({FilterStorage.legacyKey: jsonEncode(_filter)});
    final prefs = await SharedPreferences.getInstance();
    final folder = await Directory.systemTemp.createTemp('guap_filter_test_');
    addTearDown(() => folder.delete(recursive: true));
    final file = File('${folder.path}/places.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    final storage = FilterStorage(first.filterSettingsDao, prefs);
    await storage.migrateLegacy();
    await storage.migrateLegacy();
    expect(await storage.presets(), hasLength(1));
    expect(prefs.containsKey(FilterStorage.legacyKey), isFalse);
    await first.close();

    final second = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(second.close);
    final reopened = FilterStorage(second.filterSettingsDao, prefs);
    expect((await reopened.getFilter()).toJson(), _filter.toJson());
    await reopened.clear();
    expect(await reopened.presets(), isEmpty);
  });

  test('некорректный JSON оставляет SQLite и исходный ключ без изменений', () async {
    SharedPreferences.setMockInitialValues({FilterStorage.legacyKey: '{broken'});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final storage = FilterStorage(database.filterSettingsDao, prefs);
    await expectLater(storage.migrateLegacy(), throwsFormatException);
    expect(await database.filterSettingsDao.active(), isNull);
    expect(prefs.getString(FilterStorage.legacyKey), '{broken');
  });

  test('пресеты ищутся по дате и имени, активный фильтр переключается', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final dao = database.filterSettingsDao;
    final storage = FilterStorage(dao, prefs);
    final small = await dao.create('museum', _filter);
    final large = await dao.create(
      'parks',
      const FilterPlacesRequestDto(radius: 6000, typeFilter: [PlaceTypeDto.park]),
    );
    await storage.activatePreset(small);
    expect((await storage.getFilter()).radius, 1500);
    await storage.activatePreset(large);
    expect((await storage.getFilter()).radius, 6000);
    expect((await dao.presets(name: 'MUSE', from: DateTime(2020))).single.id, small);
    expect(await dao.presets(until: DateTime(2020)), isEmpty);
    await dao.updatePreset(small, 'museum updated', _filter);
    await dao.remove(small);
    expect((await dao.presets()).single.id, large);
  });

  test('настройка темы читается из нового экземпляра хранилища', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await ThemeModeStorage(prefs).saveThemeMode(mode: ThemeMode.dark);
    expect(await ThemeModeStorage(prefs).getThemeMode(), ThemeMode.dark);
  });
}
