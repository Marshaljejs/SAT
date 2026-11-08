class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  List<String> get _parts {
    return name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  }

  String get firstName => _parts.isEmpty ? name : _parts.first;

  String get initials {
    final parts = _parts;
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  UserProfile copyWith({String? name, String? email, String? phone}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
