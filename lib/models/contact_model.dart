class Contact {
  final String id;
  String name;
  String phone;
  String email;
  String? address;
  String? company;
  String? notes;
  String? avatarPath;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address,
    this.company,
    this.notes,
    this.avatarPath,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get groupKey {
    final first = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '#';
    return RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'notes': notes,
      'avatarPath': avatarPath,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String? ?? '',
      address: map['address'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
      avatarPath: map['avatarPath'] as String?,
      isFavorite: (map['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Contact && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
