import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:surf_mad_teacher_training/api/constants/assets_urls.dart';
import 'package:surf_mad_teacher_training/api/data/filter_places_request_dto.dart';
import 'package:surf_mad_teacher_training/api/data/place_dto.dart';
import 'package:surf_mad_teacher_training/api/service/api_client.dart';

/// {@template api_client_from_assets.class}
/// Реализация интерфейса для api из assets.
/// {@endtemplate}
class ApiClientFromAssets implements ApiClient {
  /// {@macro api_client_from_assets.class}
  const ApiClientFromAssets();

  @override
  Future<List<PlaceDto>> getFilteredPlaces({required FilterPlacesRequestDto filter}) async {
    final places = await getPlaces();

    final query = filter.nameFilter?.trim().toLowerCase() ?? '';
    return places.where((place) {
      final matchesCategory = filter.typeFilter?.contains(place.placeType) ?? true;
      return matchesCategory && place.name.toLowerCase().contains(query) && _withinRadius(place, filter);
    }).toList();
  }

  bool _withinRadius(PlaceDto place, FilterPlacesRequestDto filter) {
    final lat = filter.lat;
    final lng = filter.lng;
    final radius = filter.radius;
    if (lat == null || lng == null || radius == null) return true;
    const toRad = math.pi / 180;
    final halfLat = (place.lat - lat) * toRad / 2;
    final halfLng = (place.lon - lng) * toRad / 2;
    final sinLat = math.sin(halfLat);
    final sinLng = math.sin(halfLng);
    final haversine = sinLat * sinLat + math.cos(lat * toRad) * math.cos(place.lat * toRad) * sinLng * sinLng;
    final distance = 12_742_000 * math.asin(math.sqrt(haversine.clamp(0, 1)));
    return distance <= radius;
  }

  @override
  Future<List<PlaceDto>> getPlaces() async {
    final places = <PlaceDto>[];

    await _addDelay(300);
    final jsonString = await _loadAsset(AssetsUrls.places);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final placesData = data['places'] as List;

    if (placesData.isNotEmpty) {
      for (final place in placesData) {
        places.add(PlaceDto.fromJson(place as Map<String, dynamic>));
      }
    }

    return places;
  }

  /// Имитируем задержку чтобы увидеть лоадер.
  Future<void> _addDelay(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  /// Загружаем строку из asset приложения.
  Future<String> _loadAsset(String path) => rootBundle.loadString(path);
}
