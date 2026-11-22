# ПР3 — Навигация

При первом запуске пройдите онбординг или нажмите «Пропустить». Из «Мест» откройте карточку, поиск и фильтры. В каталоге и избранном карточки живут в отдельных стеках. Маршруты AutoRoute заданы в `lib/navigation/router.dart`.

## Запуск

Flutter 3.32.0, Dart 3.8.0 и настроенный Android SDK. Для проверки использован Android 15 (API 35).
На Windows для команд Flutter используйте путь без кириллицы, например через junction диска.

```text
flutter pub get
flutter run -d emulator-5554
```

## Генерация кода

При изменении моделей Drift, описаний маршрутов или JSON DTO обновите сгенерированные файлы.

```text
dart run build_runner build --delete-conflicting-outputs
```

## Исходные материалы

- [Задание SurfStudio](https://github.com/surfstudio/flutter-lab-practicum/tree/labs/lab3).
- [Исходная заготовка приложения](https://github.com/surfstudio/flutter-lab-practicum/commit/2464cf0).

- Yair Haklai, [Winter Palace - Palace Square facade](https://commons.wikimedia.org/wiki/File:Winter_Palace_-_Palace_Square_facade.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Фото уменьшено.
