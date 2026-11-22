import 'package:flutter/material.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/favorites/entities/favorites_button_type.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/favorites/favorites_button_widget_builder.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/places/entities/place_card_type.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_wm.dart';

/// Галерея и подробная информация о месте.
class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({required this.wm, required this.place, super.key});

  final IPlaceDetailWM wm;
  final PlaceEntity place;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('О месте')),
    body: ListView(
      children: [
        if (place.images.isNotEmpty)
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: wm.pageController,
                  onPageChanged: wm.onPageChanged,
                  itemCount: place.images.length,
                  itemBuilder:
                      (context, index) => Image.asset(
                        place.images[index],
                        fit: BoxFit.cover,
                        semanticLabel: 'Фотография места ${index + 1}',
                      ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ValueListenableBuilder(
                    valueListenable: wm.currentIndex,
                    builder: (context, index, _) => Chip(label: Text('${index + 1} / ${place.images.length}')),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Музей · Санкт-Петербург', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 14),
              Text(place.description),
              const SizedBox(height: 16),
              FavoritesButtonWidgetBuilder(
                place: place,
                buttonType: FavoritesButtonType.big,
                cardType: PlaceCardType.place,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
