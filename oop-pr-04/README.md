# ПР4 — Работа с сетью

Клиент использует GET /place, GET /place/{id} и POST /filtered_places. Локальный Python-сервер воспроизводит эти операции из API SurfStudio и читает набор мест из `assets/json/places.json`.

## Запуск

Flutter 3.32.0, Dart 3.8.0 и настроенный Android SDK. Для проверки использован Android 15 (API 35).
На Windows для команд Flutter используйте путь без кириллицы, например через junction диска.

В первом терминале запустите сервер из корня проекта.

```text
python server/serve.py
```

Во втором терминале подключите Android-эмулятор к локальному порту и запустите приложение.

```text
adb reverse tcp:8888 tcp:8888
flutter pub get
flutter run -d emulator-5554
```

Для другого адреса передайте `--dart-define=API_BASE_URL=https://адрес-сервера`. Локальный HTTP разрешён в отладочной Android-сборке.

## Генерация кода

При изменении моделей Drift, описаний маршрутов или JSON DTO обновите сгенерированные файлы.

```text
dart run build_runner build --delete-conflicting-outputs
```

## Исходные материалы

- [Задание SurfStudio](https://github.com/surfstudio/flutter-lab-practicum/tree/labs/lab4).
- [Исходная заготовка приложения](https://github.com/surfstudio/flutter-lab-practicum/commit/e9c84d1).
- [Контракт учебного бэкенда](https://github.com/surfstudio/flutter-course-backend).

- Yair Haklai, [Winter Palace - Palace Square facade](https://commons.wikimedia.org/wiki/File:Winter_Palace_-_Palace_Square_facade.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Фото уменьшено.
