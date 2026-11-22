/// Адреса для работы с местами.
class ApiUrls {
  // ignore: do_not_use_environment
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8888');
  // Все места что есть базе данных.
  static const String places = '/place';
  static const String placeDetails = '/place/{placeId}';
  static const String filteredPlaces = '/filtered_places';
  static const String uploadFile = '/upload_file';

  const ApiUrls._();
}
