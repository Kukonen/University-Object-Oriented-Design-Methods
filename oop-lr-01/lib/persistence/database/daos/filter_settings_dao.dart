import 'package:drift/drift.dart';
import 'package:surf_mad_teacher_training/api/data/filter_places_request_dto.dart';
import 'package:surf_mad_teacher_training/persistence/database/app_database.dart';
import 'package:surf_mad_teacher_training/persistence/database/tables/filter_settings_table.dart';

part 'filter_settings_dao.g.dart';

@DriftAccessor(tables: [FilterSettingsTable])
class FilterSettingsDao extends DatabaseAccessor<AppDatabase> with _$FilterSettingsDaoMixin {
  FilterSettingsDao(super.attachedDatabase);

  Future<FilterSettingsEntry?> active() =>
      (select(filterSettingsTable)..where((row) => row.isDefault.equals(true))).getSingleOrNull();

  Future<List<FilterSettingsEntry>> presets({String? name, DateTime? from, DateTime? until}) {
    final query = select(filterSettingsTable)..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    if (name != null && name.trim().isNotEmpty) {
      query.where((row) => row.name.lower().contains(name.trim().toLowerCase()));
    }
    if (from != null) query.where((row) => row.createdAt.isBiggerOrEqualValue(from));
    if (until != null) query.where((row) => row.createdAt.isSmallerThanValue(until));
    return query.get();
  }

  Future<int> create(String name, FilterPlacesRequestDto filter) {
    final now = DateTime.now();
    return into(filterSettingsTable).insert(
      _parameters(filter).copyWith(name: Value(name), createdAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> updatePreset(int id, String name, FilterPlacesRequestDto filter) async {
    await (update(filterSettingsTable)..where((row) => row.id.equals(id))).write(
      _parameters(filter).copyWith(name: Value(name), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> activate(int id) => transaction(() async {
    final row = await (select(filterSettingsTable)..where((row) => row.id.equals(id))).getSingleOrNull();
    if (row == null) throw StateError('Пресет $id не найден');
    await (update(filterSettingsTable)..where((row) => row.isDefault.equals(true))).write(
      const FilterSettingsTableCompanion(isDefault: Value(false)),
    );
    await (update(filterSettingsTable)..where((row) => row.id.equals(id))).write(
      const FilterSettingsTableCompanion(isDefault: Value(true)),
    );
  });

  Future<void> saveActive(FilterPlacesRequestDto filter) => transaction(() async {
    final current = await active();
    if (current == null) {
      final id = await create('Текущий фильтр', filter);
      await activate(id);
    } else {
      await updatePreset(current.id, current.name, filter);
    }
  });

  Future<void> remove(int id) async {
    await (delete(filterSettingsTable)..where((row) => row.id.equals(id))).go();
  }

  Future<void> clear() async {
    await delete(filterSettingsTable).go();
  }

  FilterSettingsTableCompanion _parameters(FilterPlacesRequestDto filter) => FilterSettingsTableCompanion(
    lat: Value(filter.lat),
    lng: Value(filter.lng),
    radius: Value(filter.radius),
    nameFilter: Value(filter.nameFilter),
    categories: Value(filter.typeFilter),
  );
}
