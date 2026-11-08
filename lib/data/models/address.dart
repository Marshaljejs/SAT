class Address {
  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.street,
    this.apartment = '',
    this.postalCode = '',
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String city;
  final String street;
  final String apartment;
  final String postalCode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get firstLine => '$city, $street';

  String get secondLine {
    final parts = <String>[
      if (apartment.isNotEmpty) '$apartment-пәтер',
      if (postalCode.isNotEmpty) postalCode,
    ];
    return parts.join(' · ');
  }

  Address copyWith({
    String? label,
    String? fullName,
    String? phone,
    String? city,
    String? street,
    String? apartment,
    String? postalCode,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'city': city,
      'street': street,
      'apartment': apartment,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: (json['label'] as String?) ?? '',
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      street: json['street'] as String,
      apartment: (json['apartment'] as String?) ?? '',
      postalCode: (json['postalCode'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
