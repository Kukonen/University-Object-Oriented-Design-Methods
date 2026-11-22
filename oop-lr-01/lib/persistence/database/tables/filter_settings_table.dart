import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surf_mad_teacher_training/api/data/place_type_dto.dart';

@DataClassName('FilterSettingsEntry')
@TableIndex(name: 'filter_settings_name', columns: {#name})
@TableIndex(name: 'filter_settings_created_at', columns: {#createdAt})
class FilterSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get radius => real().nullable()();
  TextColumn get nameFilter => text().nullable()();
  TextColumn get categories => text().map(const PlaceCategoriesConverter()).nullable()();
}

class PlaceCategoriesConverter extends TypeConverter<List<PlaceTypeDto>, String> {
  const PlaceCategoriesConverter();

  @override
  List<PlaceTypeDto> fromSql(String fromDb) {
    final names = (jsonDecode(fromDb) as List<dynamic>).cast<String>().toSet();
    return PlaceTypeDto.values.where((category) => names.contains(category.name)).toList();
  }

  @override
  String toSql(List<PlaceTypeDto> value) => jsonEncode(value.map((category) => category.name).toList());
}
