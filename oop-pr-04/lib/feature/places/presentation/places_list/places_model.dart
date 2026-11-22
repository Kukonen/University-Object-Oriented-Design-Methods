import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:surf_mad_teacher_training/core/domain/entities/result/result.dart';
import 'package:surf_mad_teacher_training/feature/filter/domain/entities/filter_places_entity.dart';
import 'package:surf_mad_teacher_training/feature/places/domain/entities/places_state.dart';
import 'package:surf_mad_teacher_training/feature/places/domain/repositories/i_places_repository.dart';

/// {@template places_model.class}
/// Модель для PlacesScreen.
/// {@endtemplate}
final class PlacesModel implements IPlacesModel {
  final IPlacesRepository _placesRepository;
  final _placesState = ValueNotifier<PlacesState>(PlacesStateLoading());
  var _request = 0;

  /// {@macro places_model.class}
  PlacesModel({required IPlacesRepository placesRepository}) : _placesRepository = placesRepository;

  @override
  ValueListenable<PlacesState> get placesStateListenable => _placesState;

  @override
  void dispose() {
    _request++;
    _placesState.dispose();
  }

  @override
  Future<FilterPlacesEntity> getSavedFilter() {
    return _placesRepository.getSavedFilter();
  }

  @override
  Future<void> getPlaces({required FilterPlacesEntity filter}) async {
    final request = ++_request;
    if (_placesState.value is! PlacesStateData) _placesState.value = const PlacesStateLoading();
    final result = await _placesRepository.getPlaces(filter: filter);
    if (request != _request) return;

    switch (result) {
      case ResultOk(:final data):
        _placesState.value = PlacesStateData(data);
      case ResultFailed(:final error):
        _placesState.value = PlacesStateFailure(error);
    }
  }
}

abstract interface class IPlacesModel {
  ValueListenable<PlacesState> get placesStateListenable;

  void dispose();

  Future<FilterPlacesEntity> getSavedFilter();

  Future<void> getPlaces({required FilterPlacesEntity filter});
}
