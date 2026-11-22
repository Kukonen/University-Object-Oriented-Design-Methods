# ПР2 — Вёрстка экранов и управление состоянием

На главном экране откройте «Онбординг», «Детали места» и «Фильтры». Галерея содержит три локальные фотографии. Фильтры показывают количество найденных мест после обработки ввода.

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

- [Задание SurfStudio](https://github.com/surfstudio/flutter-lab-practicum/tree/labs/lab2).
- [Исходная заготовка приложения](https://github.com/surfstudio/flutter-lab-practicum/commit/cca78e9).

- Yair Haklai, [Winter Palace - Palace Square facade](https://commons.wikimedia.org/wiki/File:Winter_Palace_-_Palace_Square_facade.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Фото уменьшено.
- GeoO, [Winter Palace, Saint Petersburg](https://commons.wikimedia.org/wiki/File:Winter_Palace,_Saint_Petersburg.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Фото уменьшено.
- Richard Mortel, [Palace Square with the Winter Palace and the Alexander Column](https://commons.wikimedia.org/wiki/File:Palace_Square_with_the_Winter_Palace_and_the_Alexander_Column,_St._Petersburg_(1)_(37013661756).jpg), [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/). Фото уменьшено.
