import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_mad_teacher_training/assets/strings/app_strings.dart';
import 'package:surf_mad_teacher_training/feature/app/app_builder.dart';
import 'package:surf_mad_teacher_training/feature/app/di/app_scope_register.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/places/place_card_widget.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('список → детали → добавить в избранное → новое состояние', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('first_launch', false);
    final scope = await const AppScopeRegister().createScope();
    await scope.appDatabase.favoritesDao.removeFavorite(1);
    addTearDown(() => scope.appDatabase.close());

    await tester.pumpWidget(AppBuilder(appScope: scope));
    await tester.pump(const Duration(milliseconds: 1100));
    await _waitFor(tester, find.byType(PlaceCardWidget));
    expect(find.text('Государственный Эрмитаж'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey(1)));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailScreen), findsOneWidget);

    final add = find.text(AppStrings.placeDetailsAddToFavouritesButton);
    await tester.scrollUntilVisible(add, 180, scrollable: find.byType(Scrollable).first);
    await tester.tap(add);
    final added = find.text(AppStrings.placeDetailsIsFavouritesButton);
    await _waitFor(tester, added);
    expect(added, findsOneWidget);
    expect((await scope.appDatabase.favoritesDao.fetchFavorites()).any((place) => place.placeId == 1), isTrue);
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Элемент не появился: $finder');
}
