import 'dart:async';

import 'package:flutter/material.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/filter/presentation/filter_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/presentation/onboarding_screen_builder.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_screen_builder.dart';

/// {@template index_screen.class}
/// Экран, отображающий основные возможности Scaffold.
/// {@endtemplate}
class ScaffoldScreen extends StatefulWidget {
  /// {@macro index_screen.class}
  const ScaffoldScreen({super.key});

  @override
  State<ScaffoldScreen> createState() => _ScaffoldScreenState();
}

class _ScaffoldScreenState extends State<ScaffoldScreen> {
  final _navigationBarItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
  ];

  int counter = 0;
  FilterPlacesEntity _filter = _mockFilter;

  void handlePressed({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 300)));
  }

  void handleFabPressed() {
    setState(() {
      counter += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Практическая работа 2'),
        actions: [
          IconButton(
            onPressed: () => handlePressed(context: context, message: 'Настройки нажаты'),
            icon: const Icon(Icons.settings), // onPressed:
          ),
        ],
        backgroundColor: Colors.teal[300],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: handleFabPressed,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Меню', style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text('Пункт 1')),
            ListTile(title: Text('Пункт 2')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationBarItems,
        onTap: (index) {
          handlePressed(context: context, message: 'Нажат пункт "${_navigationBarItems[index].label}"');
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text('Вёрстка экранов и управление состоянием', style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          Text('Три экрана с интерактивными элементами.'),

          const SizedBox(height: 24),

          Center(child: Text('Значение счётчика: $counter', style: TextStyle(fontWeight: FontWeight.bold))),

          const SizedBox(height: 24),

          Text('Выберите экран.'),

          const SizedBox(height: 12),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {
              unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingScreenBuilder())));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.green),
            child: Text('Онбординг'),
          ),

          FilledButton(
            onPressed: () {
              unawaited(
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => PlaceDetailScreenBuilder(place: _mockPlace))),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.yellow),
            child: Text('Детали места'),
          ),

          FilledButton(
            onPressed: () async {
              final updated = await Navigator.of(context).push<FilterPlacesEntity>(
                MaterialPageRoute(builder: (_) => FilterScreenBuilder(initialFilter: _filter)),
              );
              if (updated != null && mounted) setState(() => _filter = updated);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red),
            child: Text('Фильтры'),
          ),
        ],
      ),
    );
  }
}

const _mockPlace = PlaceEntity(
  id: 1,
  name: 'Государственный Эрмитаж',
  description:
      'Один из крупнейших и самых известных художественных музеев мира, расположенный в Санкт-Петербурге. Это одно из самых важных и общеизвестных мест в мире, которые обязательно стоит посетить каждому гостю. Осмотритесь вокруг, оцените масштабы и величие архитектурных картин.',
  type: PlaceType.museum,
  images: ['assets/images/palace-1.jpg', 'assets/images/palace-2.jpg', 'assets/images/palace-3.jpg'],
  lat: 59.9452,
  lon: 30.3245,
);

final _mockFilter = FilterPlacesEntity(lat: 59.9452, lon: 30.3245, radius: 1000, type: PlaceType.values.toSet());
