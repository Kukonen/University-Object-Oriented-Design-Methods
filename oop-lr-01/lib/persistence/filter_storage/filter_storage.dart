import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_mad_teacher_training/api/data/filter_places_request_dto.dart';
import 'package:surf_mad_teacher_training/persistence/database/app_database.dart';
import 'package:surf_mad_teacher_training/persistence/database/daos/filter_settings_dao.dart';
import 'package:surf_mad_teacher_training/persistence/filter_storage/i_filter_storage.dart';
import 'package:synchronized/synchronized.dart';

/// Реализация интерфейса фильтров на Drift с кэшем активного значения.
class FilterStorage implements IFilterStorage {
  FilterStorage(this._dao, this._preferences);

  static const legacyKey = 'filter_settings';
  final FilterSettingsDao _dao;
  final SharedPreferences _preferences;
  final Lock _lock = Lock();
  FilterPlacesRequestDto? _cached;

  /// Ключ старого хранилища удаляется после успешной записи в SQLite.
  Future<void> migrateLegacy() => _lock.synchronized(() async {
    final legacy = _preferences.getString(legacyKey);
    if (legacy == null) return;
    if (await _dao.active() == null) {
      final decoded = jsonDecode(legacy);
      if (decoded is! Map<String, dynamic>) throw const FormatException('Ожидался объект фильтра');
      final FilterPlacesRequestDto filter;
      try {
        filter = FilterPlacesRequestDto.fromJson(decoded);
      } on Object catch (error) {
        if (error is! ArgumentError && error is! TypeError) rethrow;
        throw FormatException('Некорректный прежний фильтр', error.toString());
      }
      await _dao.saveActive(filter);
    }
    await _preferences.remove(legacyKey);
    _cached = null;
  });

  @override
  Future<void> clear() => _lock.synchronized(() async {
    await _dao.clear();
    _cached = null;
  });

  @override
  Future<FilterPlacesRequestDto> getFilter() =>
      _lock.synchronized(() async => _cached ??= _fromEntry(await _dao.active()));

  @override
  Future<void> saveFilter({required FilterPlacesRequestDto filterDto}) => _lock.synchronized(() async {
    await _dao.saveActive(filterDto);
    _cached = null;
  });

  Future<List<FilterSettingsEntry>> presets() => _dao.presets();

  Future<void> savePreset(String name) => _lock.synchronized(() async {
    await _dao.create(name, _cached ?? _fromEntry(await _dao.active()));
  });

  Future<void> activatePreset(int id) => _lock.synchronized(() async {
    await _dao.activate(id);
    _cached = null;
  });

  FilterPlacesRequestDto _fromEntry(FilterSettingsEntry? entry) {
    if (entry == null) return const FilterPlacesRequestDto();
    return FilterPlacesRequestDto(
      lat: entry.lat,
      lng: entry.lng,
      radius: entry.radius,
      nameFilter: entry.nameFilter,
      typeFilter: entry.categories,
    );
  }
}
