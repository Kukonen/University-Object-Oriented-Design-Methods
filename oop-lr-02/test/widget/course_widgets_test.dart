import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_mad_teacher_training/api/service/api_client_from_assets.dart';
import 'package:surf_mad_teacher_training/assets/strings/app_strings.dart';
import 'package:surf_mad_teacher_training/feature/app/di/app_dependencies.dart';
import 'package:surf_mad_teacher_training/feature/app/di/app_scope.dart';
import 'package:surf_mad_teacher_training/feature/bottom_nav/presentation/bottom_nav_screen.dart';
import 'package:surf_mad_teacher_training/feature/common/data/converters/favorite_place_from_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/common/data/converters/favorite_place_to_db_converter.dart';
import 'package:surf_mad_teacher_training/feature/common/data/repositories/favorites_repository.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/favorites/entities/favorites_button_type.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/favorites/favorites_button_widget.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/favorites/favorites_button_wm.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/places/entities/place_card_type.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/places/place_card_widget.dart';
import 'package:surf_mad_teacher_training/feature/filter/data/converters/filter_places_converter.dart';
import 'package:surf_mad_teacher_training/feature/places/data/converters/place_response_converter.dart';
import 'package:surf_mad_teacher_training/feature/theme_mode/data/repositories/theme_mode_repository.dart';
import 'package:surf_mad_teacher_training/navigation/router.dart';
import 'package:surf_mad_teacher_training/persistence/database/app_database.dart';
import 'package:surf_mad_teacher_training/persistence/filter_storage/filter_storage.dart';
import 'package:surf_mad_teacher_training/persistence/theme_storage/theme_mode_storage.dart';
import 'package:surf_mad_teacher_training/uikit/themes/app_theme_data.dart';

const _place = PlaceEntity(
  id: 1,
  name: 'Государственный Эрмитаж',
  description: 'Музей мирового искусства',
  type: PlaceType.museum,
  images: ['assets/images/palace-1.jpg'],
  lat: 59.9452,
  lon: 30.3245,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font =
        FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    await font.load();
  });

  testWidgets('кнопка избранного передаёт место и отображает новое состояние', (tester) async {
    final wm = _FavoritesWM();
    addTearDown(wm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeData.lightTheme,
        home: Scaffold(
          body: FavoritesButtonWidget(
            wm: wm,
            place: _place,
            buttonType: FavoritesButtonType.big,
            cardType: PlaceCardType.place,
          ),
        ),
      ),
    );
    final add = find.text(AppStrings.placeDetailsAddToFavouritesButton);
    expect(add, findsOneWidget);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(wm.pressedId, _place.id);
    expect(find.text(AppStrings.placeDetailsIsFavouritesButton), findsOneWidget);
  });

  testWidgets('BottomNavScreen показывает три раздела и открывает настройки', (tester) async {
    final scope = await _testScope();
    addTearDown(() => scope.appDatabase.close());
    final router = AppRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: AppDependencies.providers(scope),
        child: MaterialApp.router(
          theme: AppThemeData.lightTheme,
          routerConfig: router.config(deepLinkBuilder: (_) => DeepLink([const BottomNavRoute()])),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(find.byType(BottomNavScreen), findsOneWidget);
    final nav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(nav.items.map((item) => item.label), ['Места', 'Избранное', 'Настройки']);
    await tester.tap(find.text('Настройки').last);
    await tester.pumpAndSettle();
    expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex, 2);
  });

  testWidgets('PlaceCardWidget совпадает с эталоном при размере 320 × 214', (tester) async {
    final scope = await _testScope();
    addTearDown(() => scope.appDatabase.close());
    const boundary = Key('golden-place-card');
    await tester.pumpWidget(
      Provider<IAppScope>.value(
        value: scope,
        child: MaterialApp(
          theme: AppThemeData.lightTheme,
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundary,
                child: SizedBox(width: 320, height: 214, child: PlaceCardWidget(place: _place, onPressed: (_) {})),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byKey(boundary));
      await precacheImage(const AssetImage('assets/images/palace-1.jpg'), context);
    });
    await tester.pumpAndSettle();
    await expectLater(find.byKey(boundary), matchesGoldenFile('goldens/place_card.png'));
  });
}

Future<IAppScope> _testScope() async {
  SharedPreferences.setMockInitialValues({'first_launch': false});
  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final themeRepository = ThemeModeRepository(themeModeStorage: ThemeModeStorage(prefs));
  await themeRepository.getThemeMode();
  const fromDb = FavoritePlaceFromDbConverter();
  const toDb = FavoritePlaceToDbConverter();

  return AppScope(
    appDatabase: database,
    sharedPreferences: prefs,
    filterStorage: FilterStorage(prefs),
    dio: Dio(),
    apiClient: const ApiClientFromAssets(),
    themeModeRepository: themeRepository,
    favoritesRepository: FavoritesRepository(
      favoritesDao: database.favoritesDao,
      fromDbConverter: fromDb,
      toDbConverter: toDb,
    ),
    favoriteFromDbConverter: fromDb,
    favoriteToDbConverter: toDb,
    filterPlacesConverter: const FilterPlacesConverter(),
    placeResponseConverter: const PlaceResponseConverter(),
  );
}

class _FavoritesWM implements IFavoritesButtonWM {
  @override
  final ValueNotifier<bool> isFavoriteState = ValueNotifier(false);
  int? pressedId;

  @override
  void onFavoritePressed(PlaceEntity place) {
    pressedId = place.id;
    isFavoriteState.value = !isFavoriteState.value;
  }

  @override
  void dispose() => isFavoriteState.dispose();
}
