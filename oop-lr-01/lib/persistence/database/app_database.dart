import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:surf_mad_teacher_training/api/data/place_type_dto.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/persistence/database/daos/favorites_dao.dart';
import 'package:surf_mad_teacher_training/persistence/database/daos/filter_settings_dao.dart';
import 'package:surf_mad_teacher_training/persistence/database/daos/history_search_dao.dart';
import 'package:surf_mad_teacher_training/persistence/database/tables/favorite_places_table.dart';
import 'package:surf_mad_teacher_training/persistence/database/tables/filter_settings_table.dart';
import 'package:surf_mad_teacher_training/persistence/database/tables/history_search_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FavoritePlacesTable,
    HistorySearchTable,
    FilterSettingsTable,
  ],
  daos: [
    FavoritesDao,
    HistorySearchDao,
    FilterSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  AppDatabase.forTesting(super.e);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade:
        (migrator, from, to) => transaction(() async {
          if (from < 2) {
            await migrator.createTable(filterSettingsTable);
            for (final index in allSchemaEntities.whereType<Index>()) {
              await migrator.createIndex(index);
            }
          }
        }),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
