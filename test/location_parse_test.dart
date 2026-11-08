import 'package:flutter_test/flutter_test.dart';
import 'package:sat_store_app/data/location/location_service.dart';

void main() {
  test('Geocoder JSON becomes delivery address fields', () {
    final location = DetectedLocation.fromGeocoder(43.238, 76.889, {
      'address': {
        'road': 'Абай даңғылы',
        'house_number': '52',
        'city': 'Алматы',
        'postcode': '050000',
      },
    });
    expect(location.city, 'Алматы');
    expect(location.street, 'Абай даңғылы, 52');
    expect(location.postalCode, '050000');
    expect(location.hasAddress, isTrue);
  });

  test('Missing address keeps only coordinates', () {
    final location = DetectedLocation.fromGeocoder(1, 2, {});
    expect(location.hasAddress, isFalse);
    expect(location.latitude, 1);
    expect(location.longitude, 2);
  });

  test('Falls back to town or village when city is missing', () {
    final location = DetectedLocation.fromGeocoder(1, 2, {
      'address': {'town': 'Талдықорған'},
    });
    expect(location.city, 'Талдықорған');
  });
}
