class UserProfile {
  final String id;
  final String phone;
  final String? name;
  final String language;
  final String role;
  final List<String> roles;
  final String? village;
  final String? district;
  final String? state;

  UserProfile({
    required this.id,
    required this.phone,
    this.name,
    required this.language,
    required this.role,
    required this.roles,
    this.village,
    this.district,
    this.state,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phone_e164'] as String? ?? '',
      name: json['name'] as String?,
      language: json['language'] as String? ?? json['preferred_language'] as String? ?? 'en',
      role: json['role'] as String? ?? (json['roles'] is List && (json['roles'] as List).isNotEmpty ? json['roles'][0] : 'farmer'),
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['farmer'],
      village: json['village'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String? ?? 'Punjab',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'language': language,
      'role': role,
      'roles': roles,
      'village': village,
      'district': district,
      'state': state,
    };
  }

  UserProfile copyWith({
    String? id,
    String? phone,
    String? name,
    String? language,
    String? role,
    List<String>? roles,
    String? village,
    String? district,
    String? state,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      language: language ?? this.language,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
    );
  }
}
