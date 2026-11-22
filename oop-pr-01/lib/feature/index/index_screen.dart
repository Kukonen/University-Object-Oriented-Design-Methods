import 'package:flutter/material.dart';
import 'package:surf_mad_teacher_training/feature/index/place_widgets.dart';

/// Демонстрация компонентов интерфейса приложения «Интересные места».
class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _tab = 0;
  String _query = '';
  bool _favorite = false;
  static const _name = 'Государственный Эрмитаж';

  void _onSearchChanged(String value) {
    debugPrint('Поиск: $value');
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final matches = _name.toLowerCase().contains(_query.trim().toLowerCase());
    return Scaffold(
      appBar: AppBar(title: const Text('Интересные места')),
      bottomNavigationBar: PlacesNavigationBar(
        currentIndex: _tab,
        onSelected: (index) => setState(() => _tab = index),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_tab == 0) SearchField(initialQuery: _query, onChanged: _onSearchChanged),
                const SizedBox(height: 16),
                if (_tab == 2)
                  const Text('Настройки приложения')
                else if (_tab == 0 ? matches : _favorite)
                  PlacePreviewCard(
                    name: _name,
                    category: 'Музей',
                    description: 'Коллекции мирового искусства в Зимнем дворце Санкт-Петербурга.',
                    imageAsset: 'assets/images/palace-1.jpg',
                    isFavorite: _favorite,
                    onFavorite: () => setState(() => _favorite = !_favorite),
                  )
                else
                  Text(_tab == 0 ? 'По вашему запросу ничего не найдено' : 'Здесь появятся избранные места'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
