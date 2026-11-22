# ЛР2 — Тестирование Flutter-приложений

Обычный прогон включает модульные, виджетные и golden-тесты. Интеграционный сценарий выполняется на Android и проверяет переход «Места → детали → избранное» и запись в SQLite.

## Запуск

Flutter 3.32.0, Dart 3.8.0 и настроенный Android SDK. Для проверки использован Android 15 (API 35).
На Windows для команд Flutter используйте путь без кириллицы, например через junction диска.

```text
flutter pub get
flutter run -d emulator-5554
```

Мобильное приложение по умолчанию читает каталог из локальных ресурсов.

## Проверки

```text
flutter analyze
flutter test
flutter test integration_test/favorites_flow_test.dart -d emulator-5554
```

Для запуска тестов с нативной SQLite на Windows требуется `sqlite3.dll` в PATH. Android получает SQLite из зависимости проекта.

## Генерация кода

При изменении моделей Drift, описаний маршрутов или JSON DTO обновите сгенерированные файлы.

```text
dart run build_runner build --delete-conflicting-outputs
```

## Исходные материалы

- [Задание SurfStudio](https://github.com/surfstudio/flutter-lab-practicum/tree/labs/lab6).
- [Исходная заготовка приложения](https://github.com/surfstudio/flutter-lab-practicum/commit/1b2776f).

- Yair Haklai, [Winter Palace - Palace Square facade](https://commons.wikimedia.org/wiki/File:Winter_Palace_-_Palace_Square_facade.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Фото уменьшено.
