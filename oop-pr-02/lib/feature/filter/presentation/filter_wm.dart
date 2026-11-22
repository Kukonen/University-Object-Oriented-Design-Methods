import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_type.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filtered_places_state.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/settings_slider_entity.dart';
import 'package:surf_mad_teacher_training/feature/filter/presentation/filter_model.dart';

const _debounceTime = Duration(milliseconds: 500);

abstract interface class IFilterWM {
  ValueListenable<FilteredPlacesState> get placesStateListenable;

  ValueListenable<Set<PlaceType>> get selectedTypesListenable;

  SettingsSliderEntity get settingsSlider;

  ValueListenable<double> get sliderValueListenable;

  void dispose();

  void onClearPressed();

  void onResultPressed();

  void onSliderChange(double sliderValue);

  void onTypePressed(PlaceType type);
}

final class FilterWM implements IFilterWM {
  final IFilterModel _model;
  final BuildContext _context;
  final FilterPlacesEntity _initialFilter;

  final _filterSubject = BehaviorSubject<FilterPlacesEntity>();
  late final StreamSubscription<FilterPlacesEntity> _filterSubscription;

  final _selectedTypes = ValueNotifier<Set<PlaceType>>({});
  final _settingsSlider = SettingsSliderEntity();

  late final _sliderValue = ValueNotifier<double>(_settingsSlider.defaultValue);

  FilterWM({required BuildContext context, required IFilterModel model, required FilterPlacesEntity initialFilter})
    : _context = context,
      _model = model,
      _initialFilter = initialFilter {
    _filterSubscription = _filterStream.debounceTime(_debounceTime).listen(_filterStreamListener);
    _initFilter();
  }

  @override
  ValueListenable<FilteredPlacesState> get placesStateListenable => _model.placesStateListenable;

  @override
  ValueListenable<Set<PlaceType>> get selectedTypesListenable => _selectedTypes;

  @override
  SettingsSliderEntity get settingsSlider => _settingsSlider;

  @override
  ValueListenable<double> get sliderValueListenable => _sliderValue;

  @override
  void dispose() {
    _selectedTypes.dispose();
    _sliderValue.dispose();
    unawaited(_filterSubscription.cancel());
    unawaited(_filterSubject.close());
    _model.dispose();
  }

  @override
  void onClearPressed() {
    final lastFilter = _filterSubject.valueOrNull ?? _initialFilter;
    final selectedTypes = Set<PlaceType>.from({});
    final radius = _settingsSlider.minValue;
    final newFilter = lastFilter.copyWith(radius: radius, type: selectedTypes);
    _filterSubject.add(newFilter);
    _selectedTypes.value = selectedTypes;
    _sliderValue.value = radius;
  }

  @override
  void onResultPressed() {
    final lastFilter = _filterSubject.valueOrNull ?? _initialFilter;
    unawaited(_model.saveFilter(filter: lastFilter));
    Navigator.of(_context).pop(lastFilter);
  }

  @override
  void onSliderChange(double sliderValue) {
    final step = _settingsSlider.stepValue;
    final rounded =
        ((sliderValue / step).round() * step).clamp(_settingsSlider.minValue, _settingsSlider.maxValue).toDouble();
    _sliderValue.value = rounded;
    final lastFilter = _filterSubject.valueOrNull ?? _initialFilter;
    _filterSubject.add(lastFilter.copyWith(radius: rounded));
  }

  @override
  void onTypePressed(PlaceType type) {
    final lastFilter = _filterSubject.valueOrNull ?? _initialFilter;
    final newSelected = Set<PlaceType>.from(_selectedTypes.value);
    // ignore: prefer-switch-with-enums
    if (newSelected.contains(type)) {
      newSelected.remove(type);
    } else {
      newSelected.add(type);
    }

    _selectedTypes.value = newSelected;
    final newFilter = lastFilter.copyWith(type: newSelected);
    _filterSubject.add(newFilter);
  }

  ValueStream<FilterPlacesEntity> get _filterStream => _filterSubject.stream;

  void _filterStreamListener(FilterPlacesEntity filter) {
    unawaited(_model.getFilteredPlaces(filter: filter));
  }

  void _initFilter() {
    _filterSubject.add(_initialFilter);
    _selectedTypes.value = _initialFilter.type ?? <PlaceType>{};
    _sliderValue.value = _initialFilter.radius ?? _settingsSlider.defaultValue;
  }
}
