import 'package:flutter/material.dart';

/// Нижняя панель с текущей вкладкой и обработчиком выбора.
class PlacesNavigationBar extends StatelessWidget {
  const PlacesNavigationBar({required this.currentIndex, required this.onSelected, super.key});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onSelected,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.list_outlined), activeIcon: Icon(Icons.list), label: 'Места'),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        activeIcon: Icon(Icons.favorite),
        label: 'Избранное',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Настройки',
      ),
    ],
  );
}

/// Поле поиска с возможностью очистить введённую строку.
class SearchField extends StatefulWidget {
  const SearchField({required this.initialQuery, required this.onChanged, super.key});

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _controller,
    builder:
        (context, value, _) => TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Поиск',
            hintText: 'Поиск интересных мест',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                value.text.isEmpty
                    ? null
                    : IconButton(
                      tooltip: 'Очистить поиск',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                      },
                    ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
  );
}

/// Карточка с фотографией, категорией, описанием и действием «Избранное».
class PlacePreviewCard extends StatelessWidget {
  const PlacePreviewCard({
    required this.name,
    required this.category,
    required this.description,
    required this.imageAsset,
    required this.isFavorite,
    required this.onFavorite,
    super.key,
  });

  final String name;
  final String category;
  final String description;
  final String imageAsset;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: Image.asset(imageAsset, fit: BoxFit.cover)),
              Positioned(
                top: 8,
                left: 8,
                child: Chip(label: Text(category)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                  onPressed: onFavorite,
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
