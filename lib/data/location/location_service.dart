import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../remote/api_client.dart';
import '../remote/api_exceptions.dart';

enum LocationFailure { serviceDisabled, denied, deniedForever, timeout, unavailable }

class DetectedLocation {
  const DetectedLocation({
    required this.latitude,
    required this.longitude,
    this.city = '',
    this.street = '',
    this.postalCode = '',
  });

  final double latitude;
  final double longitude;
  final String city;
  final String street;
  final String postalCode;

  bool get hasAddress => city.isNotEmpty || street.isNotEmpty;

  factory DetectedLocation.fromGeocoder(double latitude, double longitude, Map<String, dynamic> json) {
    final raw = json['address'];
    final address = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    String pick(List<String> keys) {
      for (final key in keys) {
        final value = address[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    final road = pick(['road', 'pedestrian', 'residential']);
    final house = pick(['house_number']);
    return DetectedLocation(
      latitude: latitude,
      longitude: longitude,
      city: pick(['city', 'town', 'village', 'municipality', 'state']),
      street: [road, house].where((part) => part.isNotEmpty).join(', '),
      postalCode: pick(['postcode']),
    );
  }
}

class LocationResult {
  const LocationResult.success(DetectedLocation this.location) : failure = null;

  const LocationResult.failure(LocationFailure this.failure) : location = null;

  final DetectedLocation? location;
  final LocationFailure? failure;

  bool get isSuccess => location != null;
}

class LocationService {
  LocationService({ApiClient? geocoder})
      : _geocoder = geocoder ??
            ApiClient(
              baseUrl: 'https://nominatim.openstreetmap.org',
              headers: const {'User-Agent': 'SATStoreApp/1.0 (student project)'},
            );

  final ApiClient _geocoder;

  Future<LocationResult> detect() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationResult.failure(LocationFailure.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(LocationFailure.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(LocationFailure.deniedForever);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final location = await _reverse(position.latitude, position.longitude);
      return LocationResult.success(location);
    } on TimeoutException {
      return const LocationResult.failure(LocationFailure.timeout);
    } catch (_) {
      return const LocationResult.failure(LocationFailure.unavailable);
    }
  }

  Future<DetectedLocation> _reverse(double latitude, double longitude) async {
    try {
      final json = await _geocoder.get(
        '/reverse',
        query: {
          'format': 'jsonv2',
          'lat': '$latitude',
          'lon': '$longitude',
          'zoom': '18',
          'addressdetails': '1',
          'accept-language': 'kk',
        },
      );
      if (json is Map) {
        return DetectedLocation.fromGeocoder(latitude, longitude, Map<String, dynamic>.from(json));
      }
    } on ApiException {
      return DetectedLocation(latitude: latitude, longitude: longitude);
    }
    return DetectedLocation(latitude: latitude, longitude: longitude);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
