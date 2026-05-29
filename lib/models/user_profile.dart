class UserProfile {
  final String id;
  String name;
  String email;
  String phone;
  String address;
  String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      avatarUrl: (data['avatarUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'avatarUrl': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class DeliveryAddress {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String zip;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.zip,
    this.isDefault = false,
  });

  String get formatted => '$street, $city, $zip';

  factory DeliveryAddress.fromMap(String id, Map<String, dynamic> data) {
    return DeliveryAddress(
      id: id,
      label: (data['label'] ?? 'Home') as String,
      fullName: (data['fullName'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      street: (data['street'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      zip: (data['zip'] ?? '') as String,
      isDefault: (data['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'zip': zip,
      'isDefault': isDefault,
    };
  }
}
