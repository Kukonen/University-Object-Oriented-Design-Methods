import 'package:flutter/material.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filtered_places_state.dart';
import 'package:surf_mad_teacher_training/feature/filter/presentation/filter_wm.dart';

/// Настройка категорий и радиуса поиска.
class FilterScreen extends StatelessWidget {
  const FilterScreen({required this.wm, required this.initialFilter, super.key});

  final IFilterWM wm;
  final FilterPlacesEntity initialFilter;

  @override
  Widget build(BuildContext context) {
    final slider = wm.settingsSlider;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
        actions: [TextButton(onPressed: wm.onClearPressed, child: const Text('Очистить'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Категории', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ValueListenableBuilder(
            valueListenable: wm.selectedTypesListenable,
            builder:
                (context, selected, _) => Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final type in PlaceType.values)
                      FilterChip(
                        label: Text(_categoryLabels[type]!),
                        selected: selected.contains(type),
                        onSelected: (_) => wm.onTypePressed(type),
                      ),
                  ],
                ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: wm.sliderValueListenable,
            builder:
                (context, radius, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Радиус поиска · ${radius.round()} м', style: Theme.of(context).textTheme.titleMedium),
                    Slider(min: slider.minValue, max: slider.maxValue, value: radius, onChanged: wm.onSliderChange),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('${slider.minValue.round()} м'), Text('${slider.maxValue.round()} м')],
                    ),
                  ],
                ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: ValueListenableBuilder(
          valueListenable: wm.placesStateListenable,
          builder:
              (context, state, _) => FilledButton(
                onPressed: state is FilteredPlacesStateData ? wm.onResultPressed : null,
                child: Text(switch (state) {
                  FilteredPlacesStateData(:final foundQuantity) => 'Показать ($foundQuantity)',
                  FilteredPlacesStateLoading() => 'Подсчёт мест…',
                  FilteredPlacesStateFailure() => 'Не удалось подсчитать места',
                }),
              ),
        ),
      ),
    );
  }
}

const _categoryLabels = {
  PlaceType.temple: 'Храмы',
  PlaceType.monument: 'Памятники',
  PlaceType.park: 'Парки',
  PlaceType.theatre: 'Театры',
  PlaceType.museum: 'Музеи',
  PlaceType.hotel: 'Отели',
  PlaceType.restaurant: 'Рестораны',
  PlaceType.cafe: 'Кафе',
  PlaceType.other: 'Прочее',
};
